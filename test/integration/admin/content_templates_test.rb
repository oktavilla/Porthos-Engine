require_relative '../../test_helper'
class ContentTemplatesTest < ActiveSupport::IntegrationCase
  setup do
    login!
  end

  test 'listing content_templates' do
    content_template = FactoryGirl.create(:content_template)

    visit admin_content_templates_path
    assert page.find("#content_templates #content_template_#{content_template.id}").has_content?(content_template.label), 'content template should be in the list'
  end

  test 'creating a content template' do
    visit admin_content_templates_path

    click_link I18n.t(:'admin.content_templates.index.new')

    assert_equal new_admin_content_template_path, current_path

    fill_in 'content_template_label', :with => 'Teaser'
    fill_in 'content_template_description', :with => 'A teaser consists of a title, text body and an image'

    click_button I18n.t(:save)

    assert has_flash_message?('Teaser'), 'Should have a flash notice about the new content template'
    assert page.find("#content .notice").has_content?(I18n.t(:'admin.content_templates.show.blank_slate')), 'Should display blank slate message'
  end

  test 'editing a content template' do
    content_template = FactoryGirl.create(:content_template)
    visit admin_content_templates_path

    within("#content_templates #content_template_#{content_template.id}") do
      click_link content_template.label
    end

    within(".header") do
      click_link I18n.t(:'admin.content_templates.show.edit')
    end

    fill_in 'content_template_label', :with => 'New awesome title'
    fill_in 'content_template_description', :with => 'A teaser consists of a title, text body and one or many image'
    click_button I18n.t(:save)

    assert has_flash_message?('New awesome title'), 'Should have a flash notice with the new label'
  end

  test "destroying a content template" do
    content_template = FactoryGirl.create(:content_template)
    visit admin_content_template_path(content_template)

    within(".header") do
      click_link I18n.t(:'admin.content_templates.show.destroy')
    end

    assert_equal admin_content_templates_path, current_path
    assert has_flash_message?(content_template.label), 'Should have a flash notice with the new title'
    refute page.has_css?("#content_templates #content_template_#{content_template.id}"), 'content template removed'
  end

end