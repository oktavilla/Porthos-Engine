require_relative '../../test_helper'
require 'launchy'
class SectionsTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @page_template = Factory.create(:page_template, :allow_node_placements => false)
  end

  test 'adding a section' do
    create_section
    assert has_flash_message?(I18n.t(:'app.admin_items.saved'))
    assert page.has_content?('A title for the section page')
  end

  test 'adding a string field' do
    create_section
    within '.tools' do
      click_link StringField.model_name.human
    end

    fill_in 'datum_label', :with => 'Summary'
    fill_in 'datum_handle', :with => 'short_summary'
    fill_in 'datum_instruction_body', :with => 'Remember to write this'
    check 'datum_multiline'
    click_button I18n.t(:save)

    assert has_flash_message?(I18n.t(:'app.admin_general.saved'))

    page.find('.datums').tap do |datums|
      assert datums.find('div.label').has_content?('Summary')
      assert datums.find('p.instructions').has_content?('Remember to write this')
    end
  end

protected

  def create_section
    visit admin_items_path(:with_page_template => @page_template.id)
    click_link I18n.t(:'admin.items.index.add_section')

    fill_in 'item_title', :with => 'A title for the section page'
    click_button I18n.t(:save)
  end

end