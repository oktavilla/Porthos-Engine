require_relative '../../test_helper'
require 'launchy'
class SectionsTest < ActiveSupport::IntegrationCase
  setup do
    @page_template = FactoryGirl.create(:page_template, :allow_node_placements => false)
  end

  test 'adding a section' do
    login!
    create_section
    assert has_flash_message?(I18n.t(:'app.admin_items.saved'))
    assert page.has_content?('A title for the section page')
  end

  test 'adding a string field' do
    Capybara.using_driver(:webkit) do
      login!
      create_a_field

      assert has_flash_message?(I18n.t(:'app.admin_general.saved'))

      page.find('.datums').tap do |datums|
        assert datums.find('div.label').has_content?('Summary')
        assert datums.find('p.instructions').has_content?('Remember to write this')
      end
    end
  end

protected

  def create_section
    visit admin_items_path(:with_page_template => @page_template.id)
    click_link I18n.t(:'admin.items.index.add_section')

    fill_in 'item_title', :with => 'A title for the section page'
    click_button I18n.t(:save)
  end

  def create_a_field
    create_section
    within '.tools' do
      click_link I18n.t(:'admin.items.section.edit_data_definitions')
    end

    within '.tools' do
      click_link I18n.t(:'admin.data.index.new')
      click_link StringField.model_name.human
    end

    fill_in 'datum_label', :with => 'Summary'
    fill_in 'datum_handle', :with => 'short_summary'
    fill_in 'datum_instruction_body', :with => 'Remember to write this'
    check 'datum_multiline'
    click_button I18n.t(:save)
  end

end
