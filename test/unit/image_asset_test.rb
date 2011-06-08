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
      @image_asset = Factory.create(:image_asset, :file => new_tempfile('image'))
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

    should 'know if is in portrait or landscape format' do
      assert @image_asset.portrait?
      assert !@image_asset.landscape?
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
