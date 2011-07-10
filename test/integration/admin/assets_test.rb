require_relative '../../test_helper'

class AssetsTest < ActiveSupport::IntegrationCase
  setup do
    WebMock.disable_net_connect!
    stub_s3_put
    stub_s3_head
    login!
  end

  teardown { WebMock.allow_net_connect! }

  test 'listning assets' do
    asset = Factory.create(:asset, :file => new_tempfile('text'))
    visit admin_assets_path

    assert page.find("ul.items #asset_#{asset.id}").has_content?(asset.name), 'Should display the asset in the assets list'
  end

  test 'uploading a new asset' do
    visit admin_assets_path

    click_link I18n.t(:'admin.assets.index.upload')

    assert_equal new_admin_asset_path, current_path

    attach_file 'asset_file', test_file_path('page.txt')
    click_button I18n.t(:'admin.assets.new.submit')

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

  test 'set cropping settings for image asset' do
    stub_resizor_post
    asset = Factory.create(:image_asset, :file => new_tempfile('image'), :versions => {'c100x100' => {}})
    visit admin_assets_path
    within("#asset_#{asset.id}") do
      click_link I18n.t(:edit)
    end
    click_link 'c100x100'
    fill_in 'cutout_width', :with => '140'
    fill_in 'cutout_height', :with => '140'
    fill_in 'cutout_x', :with => '40'
    fill_in 'cutout_y', :with => '50'
    click_button I18n.t(:save)
    visit admin_assets_path
    assert page.find("#asset_#{asset.id} img")[:src].include?("#{asset.resizor_id}.jpg?size=c100x100&cutout=140x140-40x50"), 'should use new cutout for cropping'
  end

  test 'deleting an asset' do
    stub_s3_delete
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
    asset1 = Factory.create(:asset, :title => 'Asset 1', :tag_names => 'tag1 tag2', :file => new_tempfile('text'))
    asset2 = Factory.create(:asset, :title => 'Asset 2', :tag_names => 'tag2', :file => new_tempfile('text'))
    asset3 = Factory.create(:asset, :title => 'Asset 3', :tag_names => 'tag1 tag3', :file => new_tempfile('text'))

    visit admin_assets_path(:tags => ['tag1'])

    page.find("ul.items").tap do |assets_list|
      assert assets_list.has_content?(asset1.title), 'Should display asset1 in the assets list'
      assert !assets_list.has_content?(asset2.title), 'Should not display asset2 in the assets list'
      assert assets_list.has_content?(asset3.title), 'Should display assets3 in the assets list'
    end
  end
end
