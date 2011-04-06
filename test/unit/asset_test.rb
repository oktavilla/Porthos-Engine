require_relative '../test_helper'

class AssetTest < ActiveSupport::TestCase
  context "A asset" do
    setup do
      WebMock.disable_net_connect!
      stub_s3_put
      stub_s3_head
      @asset = Factory.create(:asset, :file => new_tempfile('text'))
    end
    subject { @asset }

    should belong_to(:created_by)
    should have_many(:usages).dependent(:destroy)
    should have_many(:custom_associations).dependent(:destroy)

    # should validate_presence_of(:file).on(:create)
    # need to write matcher for validation on create
    should 'extract file attributes from uploaded file' do
      assert_equal 849, @asset.size
      assert_equal 'text/plain', @asset.mime_type
      assert_equal 'txt', @asset.extension
      assert_equal 'page', @asset.name
    end

    should 'return name for to_param' do
      assert_equal @asset.name, @asset.to_param
    end

    should 'return full name' do
      assert_equal "#{@asset.name}.#{@asset.extension}", @asset.full_name
    end

    should 'have a remote url' do
      assert_equal "http://#{Porthos.s3_storage.bucket_name}.s3.amazonaws.com/#{@asset.full_name}", @asset.remote_url
    end

    should 'be taggable' do
      @asset.update_attribute(:tag_names, 'tag1 tag2')
      assert_equal ['tag1','tag2'], @asset.tags.collect{|t| t.name }
    end

    should 'generate a unique filename' do
      new_asset = Factory.create(:asset, :file => new_tempfile('text'))
      assert_not_equal new_asset.name, @asset.name
    end

    should 'put file on s3 on create' do
      assert_requested :put, "http://#{Porthos.s3_storage.bucket_name}.s3.amazonaws.com/#{@asset.full_name}?"
    end

    should 'delete file from s3 on destroy' do
      stub_s3_delete
      @asset.destroy
      assert_requested :delete, "http://#{Porthos.s3_storage.bucket_name}.s3.amazonaws.com/#{@asset.full_name}?"
    end
  end
end
