# encoding: UTF-8
#
require_relative '../../test_helper'
class AddingDisplayOptionsTest < ActiveSupport::IntegrationCase
  setup do
    login!
    navigate_to_display_options
  end

  test 'adding a display option' do
    click_link I18n.t("admin.display_options.index.new")

    fill_in_form group_handle: "image",
                 name: "Halfwidth right",
                 css_class: "right",
                 format: "c100x100"

    click_button I18n.t(:save)

    assert page.has_content?("Halfwidth right")
  end

  test 'editing a display option' do
    FactoryGirl.create :display_option, name: "Test me"
    navigate_to_display_options

    assert page.has_content?("Test me")
    click_link I18n.t(:edit)

    fill_in_form name: "New name"
    click_button I18n.t(:save)

    refute page.has_content?("Test me")
    assert page.has_content?("New name")
  end

  test 'removing a display option' do
    FactoryGirl.create :display_option, name: 'Test me'
    navigate_to_display_options

    assert page.has_content? "Test me"

    click_link I18n.t(:destroy)

    refute page.has_content?("Test me")
  end

private

  def navigate_to_display_options
    click_link "Inställningar"
    click_link "Display Options"
  end

  def fill_in_form attributes
    [:name, :css_class, :format].each do |attribute|
      if attributes[attribute]
        fill_in DisplayOption.human_attribute_name(attribute), with: attributes[attribute]
      end
    end

    if attributes[:group_handle]
      select attributes[:group_handle], from: DisplayOption.human_attribute_name(:group_handle)
    end
  end
end

