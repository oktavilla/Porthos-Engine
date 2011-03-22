require_relative '../test_helper'

class CustomAttributeTest < ActiveSupport::TestCase
  context "A custom attribute" do
    setup do
      @field_set = Factory(:field_set)
      @field = Factory(:field, :field_set => @field_set)
      @page = Factory(:page, :field_set => @field_set)
      @custom_attribute = Factory(:custom_attribute, :field => @field, :context => @page)
    end
    subject { @custom_attribute }

    should belong_to :context
    should belong_to :field

    should parameterize_attribute :handle

    should 'use the value setter to write to subclass specific attributes' do
      @custom_attribute.instance_eval do
        self.value_attribute = :string_value
      end
      @custom_attribute.value = 'Buddy Holly'
      assert @custom_attribute.send(:string_value_changed?), "Should have triggered dirty for string_value"
      assert_equal 'Buddy Holly', @custom_attribute.value
      assert_equal 'Buddy Holly', @custom_attribute.send(:read_attribute, :string_value)
    end
  end
end