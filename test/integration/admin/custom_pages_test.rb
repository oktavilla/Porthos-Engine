require_relative '../../test_helper'
class CustomPagesTest < ActiveSupport::IntegrationCase
  setup do
    WebMock.allow_net_connect!
    stub_index_tank_put
    login!
  end

  test 'create a custom page' do
    create_page
    assert page_was_saved?
    assert_equal 'A bloody custom page', page.find('h1').text
  end

  test 'adding a field' do
    create_page
    within '.tools' do
      click_link StringField.model_name.human
    end

    fill_in 'datum_label', :with => 'Summary'
    fill_in 'datum_handle', :with => 'short_summary'
    fill_in 'datum_instruction_body', :with => 'Remember to write this'
    check 'datum_multiline'
    click_button I18n.t(:save)

    page.find('.datums').tap do |datums|
      assert datums.find('div.label').has_content?('Summary')
      assert datums.find('p.instructions').has_content?('Remember to write this')
    end
  end

  test 'editing a field' do
    create_page
    within '.tools' do
      click_link StringField.model_name.human
    end

    fill_in 'datum_label', :with => 'Summary'
    fill_in 'datum_handle', :with => 'short_summary'
    fill_in 'datum_instruction_body', :with => 'Remember to write this'
    check 'datum_multiline'
    click_button I18n.t(:save)

    within '#content' do
      click_link I18n.t(:edit)
    end
    fill_in 'datum_label', :with => 'The awesome summery!'
    click_button I18n.t(:save)

    page.find('.datums').tap do |datums|
      assert datums.find('div.label').has_content?('The awesome summery!')
    end
  end

private

  def page_was_saved?
    has_flash_message? I18n.t(:'app.admin_items.saved')
  end

  def create_page
    visit admin_items_path
    click_link CustomPage.model_name.human(count: 2)
    click_link I18n.t(:'admin.items.index.create_new', :template => CustomPage.model_name.human)
    fill_in 'item_title', with: 'A bloody custom page'
    click_button I18n.t(:save)
  end

end
