require_relative '../../test_helper'

class PagesTest < ActiveSupport::IntegrationCase
  setup do
    login!
  end

  test 'creating a page' do
    field_set = Factory(:field_set)
    visit admin_pages_path

    within('.tools') do
      click_link field_set.title
    end

    assert_equal new_admin_page_path, current_path

    fill_in 'page_title', :with => 'About us'
    fill_in 'page_uri', :with => 'about'
    click_button I18n.t(:save)

    assert_equal 'About us', page.find('h1').text

    field_set.fields.each_with_index do |field, index|
      assert_equal field.handle, page.find_field("#{field.label}").value
    end
  end

end