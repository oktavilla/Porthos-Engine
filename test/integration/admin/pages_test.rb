require_relative '../../test_helper'

class PagesTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @field_set = Factory(:field_set)
  end

  test 'creating a page' do
    visit admin_pages_path

    within('.tools') do
      click_link @field_set.title
    end

    assert_equal new_admin_page_path, current_path

    fill_in 'page_title', :with => 'About us'
    fill_in 'page_uri', :with => 'about'
    click_button I18n.t(:save)

    assert_equal 'About us', page.find('h1').text

    @field_set.fields.each_with_index do |field, index|
     # assert_equal field.label, page.find("label[for='page_data_attributes_#{index}_value']").text
    end
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
end
