require_relative '../../test_helper'
class PagesTest < ActiveSupport::IntegrationCase
  setup do
    login!
  end

  test 'listing page_templates' do
    page_template = Factory(:page_template)

    visit admin_page_templates_path
    assert page.find("#page_templates #page_template_#{page_template.id}").has_content?(page_template.title), 'Page template should be in the list'
  end

  test 'creating a page template' do
    visit admin_page_templates_path

    click_link I18n.t(:'admin.page_templates.index.new')

    assert_equal new_admin_page_template_path, current_path

    fill_in 'page_template_title', :with => 'Article'
    fill_in 'page_template_page_label', :with => 'Title'
    fill_in 'page_template_handle', :with => 'article'
    check 'page_template_allow_node_placements'

    click_button I18n.t(:save)

    assert has_flash_message?('Article'), 'Should have a flash notice about the new page template'
    assert page.find("#content .notice").has_content?(I18n.t(:'admin.page_templates.show.blank_slate')), 'Should display blank slate message'
  end

  test 'editing a page template' do
    page_template = Factory(:page_template)
    visit admin_page_templates_path

    within("#page_templates #page_template_#{page_template.id}") do
      click_link page_template.title
    end

    within(".header") do
      click_link I18n.t(:'admin.page_templates.show.edit')
    end

    fill_in 'page_template_title', :with => 'New awesome title'
    click_button I18n.t(:save)

    assert has_flash_message?('New awesome title'), 'Should have a flash notice with the new title'
  end

  test "destroying a page template" do
    page_template = Factory(:page_template)
    visit admin_page_template_path(page_template)

    within(".header") do
      click_link I18n.t(:'admin.page_templates.show.destroy')
    end

    assert_equal admin_page_templates_path, current_path
    assert has_flash_message?(page_template.title), 'Should have a flash notice with the new title'
    assert !page.has_css?("#page_templates #page_template_#{page_template.id}"), 'page template removed'
  end

end