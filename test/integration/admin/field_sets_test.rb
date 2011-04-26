require_relative '../../test_helper'

class FieldSetsTest < ActiveSupport::IntegrationCase

  setup do
    login!
  end

  test 'viewing the field set list' do
    field_set = Factory(:field_set)
    visit admin_field_sets_path

    assert page.has_css?("#field_sets #field_set_#{field_set.id}"), 'Field set should be in the list'
  end

  test 'creating a field set' do
    visit admin_field_sets_path

    click_link I18n.t(:'admin.field_sets.index.new')

    assert_equal new_admin_field_set_path, current_path

    fill_in 'field_set_title', :with => 'Article'
    fill_in 'field_set_page_label', :with => 'Title'
    fill_in 'field_set_handle', :with => 'article'
    check 'field_set_allow_node_placements'
    click_button I18n.t(:save)

    within(".flash.notice") do
      assert_match 'Article', page.body
    end

    within("#content .notice") do
      assert_match I18n.t(:'admin.field_sets.show.blank_slate'), page.body
    end
  end

  test 'editing a field set' do
    field_set = Factory(:field_set)
    visit admin_field_sets_path

    within("#field_sets #field_set_#{field_set.id}") do
      click_link field_set.title
    end

    within(".header") do
      click_link I18n.t(:'admin.field_sets.show.edit')
    end

    fill_in 'field_set_title', :with => 'New awesome title'
    click_button I18n.t(:save)

    within(".flash.notice") do
      assert_match 'New awesome title', page.body
    end
  end

  test "destroying a field set" do
    field_set = Factory(:field_set)
    visit admin_field_set_path(field_set)

    within(".header") do
      click_link I18n.t(:'admin.field_sets.show.destroy')
    end

    assert_equal admin_field_sets_path, current_path

    within(".flash.notice") do
      assert_match field_set.title, page.body
    end
    assert !page.has_css?("#field_sets #field_set_#{field_set.id}"), 'Field set removed'
  end

end