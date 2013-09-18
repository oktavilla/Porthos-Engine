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

  test 'updating section and node details' do
    Capybara.using_driver(:webkit) do
      FactoryGirl.create(:node, :handle => @page_template.handle)
      login!
      create_section

      within '#item_attributes' do
        click_link I18n.t(:edit)
      end

      within 'form.edit_item' do
        fill_in 'item_title', :with => 'All pages'
        fill_in 'item_node_name', :with => "The pages page"
        click_button I18n.t(:save)
      end

      assert page.find('.header .page_title h1').has_content?('All pages')
      assert page.find('.navigation').has_content?('The pages page')
    end
  end

protected

  def create_section
    visit admin_items_path(:with_page_template => @page_template.id)
    click_link I18n.t(:'admin.items.index_for_page_template.add_section')

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
