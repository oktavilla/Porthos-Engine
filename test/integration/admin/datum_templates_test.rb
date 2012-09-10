require_relative '../../test_helper'

class DatumTemplatesTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @page_template = FactoryGirl.create(:page_template)
  end

  # TODO: Add tests for the different kinds of datum_templates and their forms
  test 'creating a string datum_template' do
    visit admin_page_template_path(@page_template)
    click_link I18n.t(:"admin.page_templates.show.string")

    within("form.new_datum_template") do
      assert_equal StringFieldTemplate.model_name, page.find('#template_type').value

      fill_in "datum_template_label", :with => 'Description'
      fill_in "datum_template_handle", :with => 'description'
      check "datum_template_required"
      fill_in "datum_template_instruction_body", :with => 'Please put in a descriptive description'
      check 'datum_template_multiline'
      check 'datum_template_allow_rich_text'

      click_button I18n.t(:save)
    end

    assert_equal admin_page_template_path(@page_template), current_path
    assert has_flash_message?('Description'), 'Should have a flash notice about the datum_template'
    assert page.find("#datum_templates").has_content?('Description'), 'Should display the template in the templates list'
  end

  test 'editing a datum_template' do
    datum_template = @page_template.datum_templates.first

    visit admin_page_template_path(@page_template)
    within("#datum_template_#{datum_template.id}") do
      click_link I18n.t(:edit)
    end

    assert_equal edit_admin_template_datum_template_path(@page_template, datum_template), current_path

    fill_in "datum_template_label", :with => 'Page Description'
    click_button I18n.t(:save)

    assert has_flash_message?('Page Description'), 'Should have a flash notice about the datum_template'
    assert page.find("#datum_templates #datum_template_#{datum_template.id}").has_content?('Page Description'), "Should have changed the label"
  end

  test 'destroying a datum_template' do
    page_template = FactoryGirl.create(:page_template, :datum_templates => [ FactoryGirl.build(:datum_template) ])
    datum_template = page_template.datum_templates.first

    visit admin_page_template_path(page_template)
    within("#datum_template_#{datum_template.id}") do
      click_link I18n.t(:destroy)
    end

    assert_equal admin_page_template_path(page_template), current_path
    assert has_flash_message?(datum_template.label), 'Should have a flash notice about the datum_template'
    assert page.find("#content").has_no_content?(datum_template.label), 'Should not have the datum_template in the datum_templates list'
  end
end
