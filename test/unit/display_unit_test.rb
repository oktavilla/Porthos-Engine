require_relative '../test_helper'
require 'minitest/autorun'

describe DisplayOption do
  before :each do
    DatabaseCleaner.clean
  end

  it "touches items associated with it" do
    display_option = FactoryGirl.create :display_option
    section = FactoryGirl.build :section
    section.data << AssetAssociation.new(display_option: display_option)
    section.save

    section.expects(:touch).once

    display_option.update_attributes css_class: "new-stuff"
  end
end
