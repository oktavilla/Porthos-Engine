require_relative '../test_helper'

class ImageAssetTest < ActiveSupport::TestCase
  context "A image asset" do
    setup do
      Resizor.configure do |config|
        config.api_key = 'test-api-key'
      end
      WebMock.disable_net_connect!
      stub_resizor_post
      stub_resizor_delete
      @image_asset = FactoryGirl.create(:image_asset, :file => new_tempfile('image'))
    end

    should 'set correct file type' do
      assert_equal 'image', @image_asset.filetype
    end

    should 'return its original path' do
      assert @image_asset.remote_url.include?("/assets/1.jpg?size=original&token=")
    end

    should 'return Resizor version url for size' do
      assert @image_asset.version_url(:size => 'w200').include?("assets/1.jpg?size=w200&token=")
    end

    should 'save cropping settings if present when genrating version url' do
      @image_asset.version_url(:size => 'c200x100')
      @image_asset.reload
      assert @image_asset.versions.has_key?('c200x100'), 'should save cropping info in versions array'
    end

    should 'append cutout settings if present when generating version url' do
      @image_asset.versions['c200x100'] = { :cutout_width => '500', :cutout_height => '400',
        :cutout_x => '10', :cutout_y => '20' }
      assert @image_asset.version_url(:size => 'c200x100').include?("1.jpg?size=c200x100&cutout=500x400-10x20&token="),
        'should include cutout settings in url'
    end

    should 'know if is in portrait or landscape format' do
      assert @image_asset.portrait?
      refute @image_asset.landscape?
    end

    context 'on create' do
      should 'save image to resizor' do
        assert_requested(:post, "https://resizor.com:443/assets.json")
      end

      should 'assign data from resizor' do
        assert_equal 332, @image_asset.width
        assert_equal 500, @image_asset.height
        assert_equal 1, @image_asset.resizor_id
      end
    end

    context 'on delete' do
      setup { @image_asset.destroy }
      should 'delete image from resizor' do
        assert_requested :delete, "https://resizor.com:443/assets/1.json?api_key=test-api-key", :times => 1
      end
    end
  end
end
