require_relative '../test_helper'

class AssetAssociationTest < ActiveSupport::TestCase
  context "A asset association" do
    setup do
      Resizor.configure do |config|
        config.api_key = 'test-api-key'
      end
      WebMock.disable_net_connect!
      stub_resizor_post
      stub_s3_put
      stub_s3_head
      @asset = Factory.create(:image_asset, {
        title: 'A fine image',
        description: 'Looks good it does',
        author: 'God',
        file: new_tempfile('image')
      })
      @page = Factory.build(:page)
      @asset_association = AssetAssociation.new(:asset => @asset)
      @page.data << @asset_association
    end

    should 'have an asset' do
      assert_equal @asset, @asset_association.asset
    end

    context 'reading asset attributes' do
      setup do
        @attrs = %w{title description author}
      end

      should 'delegate attributes to asset' do
        @attrs.each do |attribute|
          assert_nil @asset_association[attribute]
          assert_equal @asset[attribute], @asset_association.public_send(attribute)
        end
      end

      should 'use own attributes when set' do
        @asset_association.attributes = {
          :title => 'A very own title',
          :description => 'A very own description',
          :author => 'Someone else'
        }
        @attrs.each do |attribute|
          refute_equal @asset[attribute], @asset_association.public_send(attribute)
        end
      end
    end

    should "notify asset about it's context when created" do
      pending 'FAILS for some reason ?'
      assert_equal [], @asset['_usages']
      @asset_association.save && @asset.reload
      assert @asset.usages.include?(@asset_association._root_document)
    end

    context 'when changing the asset_id' do
      setup do
        @asset_association.save
        @new_asset = Factory.create(:image_asset, {
          title: 'A finer image',
          description: 'Looks gooder it does',
          author: 'Gods',
          file: new_tempfile('image')
        })
        @asset_association.update_attributes(asset_id: @new_asset.id)
        @asset.reload
        @new_asset.reload
      end

      should 'notify the old asset' do
        refute @asset.usages.include?(@asset_association._root_document), "Old asset should no longer know about the asset_association"
      end

      should 'notify the new asset' do
        pending 'FAILS for some reason ?'
        assert @new_asset.usages.include?(@asset_association._root_document), "New asset should know about the asset_association"
      end
    end

  end
end
