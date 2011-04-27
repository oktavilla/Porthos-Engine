require_relative '../../test_helper'

class FieldsTest < ActiveSupport::IntegrationCase

  setup do
    login!
  end

  # TODO: Add tests for the different kinds of fields and their forms
  test 'creating a string field' do
    field_set = Factory(:field_set)
    visit admin_field_set_path(field_set)
    select Field.types.first.model_name.human, :from => "field_type"
    click_button I18n.t(:'admin.field_sets.show.add_field')

    within("form.field_new") do
      assert_equal Field.types.first.model_name, page.find('#field_type').value

      fill_in "field_label", :with => 'Description'
      fill_in "field_handle", :with => 'description'
      check "field_required"
      fill_in "field_instructions", :with => 'Please put in a descriptive description'
      check 'field_multiline'
      check 'field_allow_rich_text'

      click_button I18n.t(:save)
    end

    assert_equal admin_field_set_path(field_set), current_path
    assert has_flash_message?('Description'), 'Should have a flash notice about the field'
    assert page.find("#fields").has_content?('Description'), 'Should display the field in the fields list'
  end

  test 'editing a field' do
    field_set = Factory(:field_set)
    field = field_set.fields.first

    visit admin_field_set_path(field_set)
    within("#field_#{field.id}") do
      click_link I18n.t(:edit)
    end

    assert_equal edit_admin_field_set_field_path(field_set, field), current_path

    fill_in "field_label", :with => 'Page Description'
    click_button I18n.t(:save)

    assert has_flash_message?('Page Description'), 'Should have a flash notice about the field'
    assert page.find("#fields #field_#{field.id}").has_content?('Page Description'), "Should have changed the label"
  end

  test 'destroying a field' do
    field_set = Factory(:field_set, :fields => [ Factory.build(:field) ])
    field = field_set.fields.first

    visit admin_field_set_path(field_set)
    within("#field_#{field.id}") do
      click_link I18n.t(:destroy)
    end

    assert_equal admin_field_set_path(field_set), current_path
    assert has_flash_message?(field.label), 'Should have a flash notice about the field'
    assert page.find("#content").has_no_content?(field.label), 'Should not have the field in the fields list'
  end
end