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

    assert page.find("ul.items #asset_#{asset.id}").has_content?(asset.name), 'Should display the asset in the assets list'
  end

  test 'uploading a new asset' do
    login!
    visit admin_assets_path

    click_link I18n.t(:'app.views.assets.index.upload_files')

    assert_equal new_admin_asset_path, current_path

    attach_file 'asset_file', test_file_path('page.txt')
    click_button I18n.t(:'app.views.assets.new.submit')

    assert_equal incomplete_admin_assets_path, current_path

    fill_in 'asset_0_title', :with => 'My file'
    fill_in 'asset_0_description', :with => 'A file about stuff'
    fill_in 'asset_0_author', :with => 'A. User'
    fill_in 'asset_0_tag_names', :with => 'my-tag'
    click_button I18n.t(:save)

    assert_equal admin_assets_path, current_path
    assert page.find("ul.items").has_content?('My file')
    assert page.find('ul.items').has_content?('A file about stuff')
    assert page.find('ul.items').has_content?('my-tag')
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

    assert_equal admin_assets_path, current_path
    assert page.find("#asset_#{asset.id}").has_content?('My updated file'), 'Should show the new asset name'
  end

  test 'deleting an asset' do
    stub_s3_delete
    login!
    asset = Factory.create(:asset, :file => new_tempfile('text'))
    visit admin_assets_path

    within("#asset_#{asset.id}") do
      click_link I18n.t(:destroy)
    end

    assert_equal admin_assets_path, current_path
    assert page.has_no_css?("asset_#{asset.id}"), 'Asset removed from page body'
    assert Asset.count.zero?, 'Asset deleted from db'
  end

  test 'listning assets by tag' do
    login!
    asset1 = Factory.create(:asset, :tag_names => 'tag1 tag2', :file => new_tempfile('text'))
    asset2 = Factory.create(:asset, :tag_names => 'tag2', :file => new_tempfile('text'))
    asset3 = Factory.create(:asset, :tag_names => 'tag1 tag3', :file => new_tempfile('text'))
    visit admin_assets_path(:tags => ['tag1'])
    assert page.find("ul.items").has_content?(asset1.name), 'Should display asset1 in the assets list'
    assert !page.find("ul.items").has_content?(asset2.name), 'Should not display asset2 in the assets list'
    assert page.find("ul.items").has_content?(asset3.name), 'Should display assets3 in the assets list'
  end
end
