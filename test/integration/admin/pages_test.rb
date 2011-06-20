require_relative '../../test_helper'
require 'launchy'
class PagesTest < ActiveSupport::IntegrationCase
  setup do
    WebMock.allow_net_connect!
    stub_index_tank_put
    login!
    @page_template = Factory.create(:hero_page_template)
  end

  test 'listning pages by tag' do
    page1 = Page.create_from_template(@page_template, :title => 'Page no1', :tag_names => 'tag1 tag2')
    page2 = Page.create_from_template(@page_template, :title => 'Page no2', :tag_names => 'tag2')
    page3 = Page.create_from_template(@page_template, :title => 'Page no3', :tag_names => 'tag1 tag3')

    visit admin_pages_path(:tags => ['tag1'])

    assert page.find("table#pages").has_content?(page1.title), 'Should display page1 in the pages list'
    assert page.find("table#pages").has_content?(page3.title), 'Should display page2 the pages list'
    refute page.find("table#pages").has_content?(page2.title), 'Should not display page2 in the pages list'
  end

  test 'creating a page' do
    visit admin_pages_path

    within('#sub_nav') do
      click_link @page_template.label
    end

    within('.tools') do
      click_link I18n.t(:'admin.pages.index.create_new', :template => @page_template.label.downcase)
    end

    assert_equal new_admin_page_path, current_path

    fill_in 'page_title', :with => 'Batman'
    fill_in 'page_uri', :with => 'batman'
    click_button I18n.t(:save)

    assert has_flash_message? I18n.t(:saved, :scope => [:app, :admin_pages])
    assert_equal 'Batman', page.find('h1').text
  end

  test 'publishing a page without all required data' do
    Capybara.using_driver(:selenium) do
      # Need to reset env/session for selenium
      User.delete_all
      login!
      batman = create_page
      batman.data.each { |d| d.required = true }

      visit admin_page_path(batman.id)

      publish
      refute published?, "Should not get published (NOT IMPLEMENTED)"
    end
  end

  test 'publishing a page' do
    Capybara.using_driver(:selenium) do
      # Need to reset env/session for selenium
      User.delete_all
      login!
      batman = create_page
      batman.data.each { |d| d.required = false } && batman.save

      assert batman.valid?

      visit admin_page_path(batman.id)
      publish

      assert published?, "Should get published"
    end
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

  test 'categorizing a page' do
    Capybara.using_driver(:selenium) do
      # Need to reset env/session for selenium
      User.delete_all
      login!
      @page_template.update_attribute(:allow_categories, true)
      new_page = Page.create_from_template(@page_template, :title => 'Category page')
      visit admin_page_path(new_page)
      click_link I18n.t(:'admin.pages.show.choose_category')
      click_link I18n.t(:'admin.pages.show.add_new_category')
      fill_in "page_#{@page_template.handle}_tag_names", :with => 'Beverages'
      click_button I18n.t(:save)
      assert page.find('#page_category').has_content?('Beverages'), 'Category should be added'
      refute page.find('#page_tags p').has_content?('Beverages'), 'category should not be listed as a tag'
    end
  end

  test 'changing category for a page' do
    Capybara.using_driver(:selenium) do
      User.delete_all
      login!
      @page_template.update_attribute(:allow_categories, true)
      sausage_page = Factory.create(:page, :page_template => @page_template, :"#{@page_template.handle}_tag_names" => 'Sausages')
      new_page = Factory.create(:page, :page_template => @page_template, :"#{@page_template.handle}_tag_names" => 'Beverages')
      visit admin_page_path(new_page)
      click_link I18n.t(:'admin.pages.show.edit_category')
      select 'Sausages', :from => "page_#{@page_template.handle}_tag_names"
      click_button I18n.t(:choose)
      assert page.find('#page_category p').has_content?('Sausages'), "Category should be added"
    end
  end

  test 'deleting a page' do
    a_page = create_page
    visit admin_page_path(a_page)

    within 'div.header' do
      click_link I18n.t(:destroy)
    end

    assert_equal admin_pages_path, current_path
    assert has_flash_message?(I18n.t(:'app.admin_general.deleted'))
  end

protected

  def create_page
    Page.create_from_template(@page_template, :title => 'Batman')
  end

  def publish
    within "#page_current_publish_on_date" do
      click_link I18n.t(:'admin.pages.show.publish_now')
    end
  end

  def published?
    !page.has_content? I18n.t(:'admin.pages.show.not_published')
  end
end
