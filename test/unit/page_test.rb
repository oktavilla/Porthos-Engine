require_relative '../test_helper'

class PageTest < ActiveSupport::TestCase

  setup do
    @page = Factory.build(:page, :field_set => Factory.build(:field_set))
    @page.clone_field_set
  end

  test 'published_on should be less than now to be published' do
    @page.published_on = nil
    assert !@page.published?
    @page.published_on = Date.today + 1.day
    assert !@page.published?
    @page.published_on = Time.now - 1.minute
    assert @page.published?
  end

  test "data is created from fields" do
    @page.field_set.fields.each do |field|
      assert @page.data.one? { |datum| datum.handle == field.handle }, "should have had a datum with handle #{field.handle}"
    end
  end

  test "accessing data values by their handles" do
    @page.data = [
      Datum.from_field(Factory.build(:string_field, :handle => 'short_description'), :value => 'A string'),
      Datum.from_field(Factory.build(:boolean_field, :handle => 'awesome'), :value => true)
    ]
    assert @page.respond_to?('short_description'), "Should respond to short_description"
    assert_equal 'A string', @page.short_description, "Should return the string datum's value"
    assert @page.respond_to?('awesome'), "Should respond to the boolean datum's handle"
    assert true === @page.awesome, "Should return the boolean datum's value"
    assert true === @page.awesome?
  end

end
