require_relative '../test_helper'

class DateTimeAttributeTest < ActiveSupport::TestCase
  context 'A date time attribute' do
    setup do
      @field_set = Factory(:field_set)
      @field = Factory(:field, :field_set => @field_set)
      @page = Factory(:page, :field_set => @field_set)
      @date_time_attribute = Factory(:date_time_attribute, :field => @field, :context => @page)
    end

    should "be able to take a hash when setting it's value" do
      @date_time_attribute.value = { :year => '2001', :month => '01', :day => '01', :hour => '01', :minute => '01' }
      assert_equal '2001-01-01', @date_time_attribute.value.strftime("%Y-%m-%d")
    end
  end
end