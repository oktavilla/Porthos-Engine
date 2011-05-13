require_relative '../../test_helper'
require 'launchy'
class PagesTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @field_set = Factory(:hero_field_set)
  end

  test 'creating a page' do
    visit admin_pages_path

    within('.tools') do
      click_link @field_set.title
    end

    assert_equal new_admin_page_path, current_path

    fill_in 'page_title', :with => 'Batman'
    fill_in 'page_uri', :with => 'batman'
    click_button I18n.t(:save)

    assert has_flash_message? I18n.t(:saved, :scope => [:app, :admin_pages])
    assert_equal 'Batman', page.find('h1').text
  end

  test 'publishing a page without all required data' do
    batman = create_page
    visit admin_page_path(batman.id)
    publish
    assert !published?, "Should not get published"
  end

  test 'editing page datum attributes' do
    batman = create_page
    visit admin_page_path(batman.id)

    within "form#datum_#{batman.data['tagline'].id}_edit" do
      fill_in 'Tagline', :with => 'Evil Fears The Knight'
      click_button I18n.t(:save)
    end

    assert has_flash_message?(I18n.t(:saved, :scope => [:app, :admin_pages]))
    assert page.has_content?('Evil Fears The Knight'), "Should find the tagline within content"
  end

  test 'listning pages by tag' do
    page1 = Factory.create(:page, :field_set => @field_set, :tag_names => 'tag1 tag2')
    page2 = Factory.create(:page, :field_set => @field_set, :tag_names => 'tag2')
    page3 = Factory.create(:page, :field_set => @field_set, :tag_names => 'tag1 tag3')
    visit admin_pages_path(:tags => ['tag1'])

    assert page.find("ul.items").has_content?(page1.title), 'Should display page1 in the pages list'
    assert page.find("ul.items").has_content?(page3.title), 'Should display page2 the pages list'
    assert !page.find("ul.items").has_content?(page2.title), 'Should not display page2 in the pages list'
  end

  test 'categorizing a page' do
    Capybara.using_driver(:selenium) do
      # Need to reset env/session for selenium
      User.delete_all
      login!
      @field_set.update_attribute(:allow_categories, true)
      new_page = Factory.create(:page, :field_set => @field_set)
      visit admin_page_path(new_page)
      click_link I18n.t(:'admin.pages.show.choose_category')
      click_link I18n.t(:'admin.pages.show.add_new_category')
      fill_in "page_#{@field_set.handle}_tag_names", :with => 'Beverages'
      click_button I18n.t(:save)
      assert page.find('#page_category p').has_content?('Beverages'), "Category should be added"
    end
  end

  test 'changing category for a page' do
    Capybara.using_driver(:selenium) do
      User.delete_all
      login!
      @field_set.update_attribute(:allow_categories, true)
      sausage_page = Factory.create(:page, :field_set => @field_set, :"#{@field_set.handle}_tag_names" => 'Sausages')
      new_page = Factory.create(:page, :field_set => @field_set, :"#{@field_set.handle}_tag_names" => 'Beverages')
      visit admin_page_path(new_page)
      click_link I18n.t(:'admin.pages.show.edit_category')
      select 'Sausages', :from => "page_#{@field_set.handle}_tag_names"
      click_button I18n.t(:choose)
      assert page.find('#page_category p').has_content?('Sausages'), "Category should be added"
    end
  end

protected

  def create_page
    page = Factory.build(:page, :field_set => @field_set, :title => 'Batman', :uri => 'batman')
    page.clone_field_set
    page.save
    page
  end

  def publish
    within "#page_publish_on_date" do
      click_link I18n.t(:'admin.pages.show.publish_now')
    end
  end

  def published?
    page.find('#page_current_publish_on_date').has_content? I18n.t(:'admin.pages.show.not_published')
  end
end