require_relative '../../test_helper'

class AssetsTest < ActiveSupport::IntegrationCase
  setup do
      WebMock.disable_net_connect!
      stub_s3_put
      stub_s3_head
  end
  teardown { WebMock.allow_net_connect! }

  test 'listning assets' do
    login!
    asset = Factory.create(:asset, :file => new_tempfile('text'))
    visit admin_assets_path

    assert_match asset.name, page.body
  end

  test 'uploading a new asset' do
    login!
    visit admin_assets_path

    click_link I18n.t(:'app.views.assets.index.upload_files')

    assert_equal '/admin/assets/new', current_path

    attach_file 'asset_file', test_file_path('page.txt')
    click_button I18n.t(:'app.views.assets.new.submit')

    assert_equal '/admin/assets/incomplete', current_path

    fill_in 'asset_0_title', :with => 'My file'
    fill_in 'asset_0_description', :with => 'A file about stuff'
    fill_in 'asset_0_author', :with => 'A. User'
    click_button I18n.t(:save)

    assert_equal '/admin/assets', current_path
    assert_match 'My file', page.body
    assert_match 'A file about stuff', page.body
  end

  test 'editing a asset' do
    login!
    asset = Factory.create(:asset, :file => new_tempfile('text'))
    visit admin_assets_path

    within("#asset_#{asset.id}") do
      click_link I18n.t(:edit)
    end
    fill_in 'asset_title', :with => 'My updated file'
    click_button I18n.t(:save)

    assert_equal '/admin/assets', current_path
    within("#asset_#{asset.id}") do
      assert_match 'My updated file', page.body
    end
  end

  test 'deleting an asset' do
    stub_s3_delete
    login!
    asset = Factory.create(:asset, :file => new_tempfile('text'))
    visit admin_assets_path

    within("#asset_#{asset.id}") do
      click_link I18n.t(:destroy)
    end

    assert_equal '/admin/assets', current_path
    assert !page.body.include?("asset_#{asset.id}"), 'Asset removed from page body'
    assert Asset.count.zero?, 'Asset deleted from db'
  end
end
