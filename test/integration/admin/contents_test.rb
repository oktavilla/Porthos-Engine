require_relative '../../test_helper'

class ContentsTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @page = Factory.build(:page)
    @page.clone_field_set
    @page.save!
  end

  test 'adding a textfield' do
    create_textfield
    assert has_flash_message?(I18n.t(:saved, :scope => [:app, :admin_general]))
    assert page.find("div.datum.content_block").has_content?('Some text for this page'), 'Should see the textfield in the contents list'
  end

  test 'editing a textfield' do
    create_textfield
    within "div.datum.content_block li.content.textfield" do
      click_link I18n.t(:edit)
    end

    fill_in 'content_body', :with => 'Some new text'
    click_button I18n.t(:save)

    assert has_flash_message?(I18n.t(:saved, :scope => [:app, :admin_general]))
    assert page.find("div.datum.content_block").has_content?('Some new text'), 'Should see the new text for the textfield'
  end

  test 'destroying a textfield' do
    create_textfield
    within "div.datum.content_block li.content.textfield" do
      click_link I18n.t(:destroy)
    end
    assert has_flash_message?(I18n.t(:deleted, :scope => [:app, :admin_general]))
    assert !page.has_content?('Some text for this page')
  end

  test 'adding a teaser' do
    create_teaser
    assert has_flash_message?(I18n.t(:saved, :scope => [:app, :admin_general]))
    assert page.find("div.datum.content_block").has_content?('Teaser heading'), 'Should see the teaser in the contents list'
  end

  test 'editing a teaser' do
    create_teaser
    within "div.datum.content_block li.content.teaser" do
      click_link I18n.t(:edit)
    end

    fill_in 'content_title', :with => 'A new teaser heading'
    click_button I18n.t(:save)

    assert has_flash_message?(I18n.t(:saved, :scope => [:app, :admin_general]))
    assert page.find("div.datum.content_block").has_content?('A new teaser heading'), 'Should see the new title for the teaser'
  end

  test 'adding an image to a teaser' do
    image = create_image_asset
    create_teaser
    within "div.datum.content_block li.content.teaser" do
      click_link I18n.t(:edit)
    end

    click_link I18n.t(:'admin.contents.teasers.edit.add_image')

    assert_equal admin_assets_path, current_path

    within "#asset_#{image.id}" do
      click_button I18n.t(:choose)
    end

    assert_equal admin_page_path(@page), current_path
    assert has_flash_message?(I18n.t(:saved, :scope => [:app, :admin_general]))
    assert page.find('div.datum.content_block li.content.teaser').has_css?('#assets')
  end

  test 'destroying a teaser' do
    create_teaser
    within "div.datum.content_block li.content.teaser" do
      click_link I18n.t(:destroy)
    end

    assert has_flash_message?(I18n.t(:deleted, :scope => [:app, :admin_general]))
    assert !page.has_content?('Teaser heading')
  end

  test 'adding a image' do
    create_image
    assert has_flash_message?(I18n.t(:saved, :scope => [:app, :admin_general]))
    assert page.find("div.datum.content_block").has_content?('My image'), 'Should see the image in the contents list'
  end

  test 'editing an image' do
    create_image
    within "div.datum.content_block li.content.image" do
      click_link I18n.t(:edit)
    end

    fill_in 'content_title', :with => 'Their image'
    click_button I18n.t(:save)

    assert has_flash_message?(I18n.t(:saved, :scope => [:app, :admin_general]))
    assert page.find("div.datum.content_block").has_content?('Their image'), 'Should see the new title for the image'
  end

  test 'destroying an image' do
    create_image
    within "div.datum.content_block li.content.image" do
      click_link I18n.t(:destroy)
    end

    assert has_flash_message?(I18n.t(:deleted, :scope => [:app, :admin_general]))
    assert !page.has_content?('My image')
  end

protected

  def create_textfield
    visit admin_page_path(@page)
    within "div.datum.content_block div.controls" do
      click_link Textfield.model_name.human
    end

    fill_in 'content_body', :with => 'Some text for this page'
    click_button I18n.t(:save)
  end

  def create_teaser
    visit admin_page_path(@page)
    within "div.datum.content_block div.controls" do
      click_link Teaser.model_name.human
    end
    fill_in 'content_title', :with => 'Teaser heading'
    fill_in 'content_body', :with => 'Teaser body'
    click_button I18n.t(:save)
  end

  def create_image
    image = create_image_asset
    visit admin_page_path(@page)
    within "div.datum.content_block div.controls" do
      click_link Image.model_name.human
    end
    within "#asset_#{image.id}" do
      click_button I18n.t(:choose)
    end

    fill_in 'content_title', :with => 'My image'
    click_button I18n.t(:save)
  end

  def create_image_asset
    Resizor.configure do |config|
      config.api_key = 'test-api-key'
    end
    WebMock.disable_net_connect!
    stub_resizor_post
    Factory.create(:image_asset, :file => new_tempfile('image'))
  end

end