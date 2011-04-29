require_relative '../test_helper'

class DatumTest < ActiveSupport::TestCase

  test 'creating a datum from a field' do
    field = Factory.build(:string_field)
    datum = Datum.from_field(field)
    assert_equal field.label, datum.label, "Should have cloned the fields's label"
    assert_equal field.handle, datum.handle, "Should have cloned the fields's handle"
    assert_equal field.required?, datum.required?, "Should have cloned the fields's required?"
    assert_equal 'string', datum.input_type, "Should have set the input_type from the fields class name"
  end

  test 'type casting the value for a boolean' do
    datum = Datum.from_field(Factory.build(:boolean_field))
    ['1', 1, true, 'true', 't'].each do |bool|
      test_set_value datum, bool, true
    end

    ['0', 0, false, 'false', 'f'].each do |bool|
      test_set_value datum, bool, false
    end
  end

  test 'type casting the value for a date time' do
    datum = Datum.from_field(Factory.build(:date_time_field))
    now = DateTime.now
    date_time_string = now.strftime("%Y-%m-%d %H:%I")

    datum.value = date_time_string
    assert_date_value datum, date_time_string, 'When using a date time string'

    datum.value = {
      'year'   => now.strftime("%Y"),
      'month'  => now.strftime("%m"),
      'day'    => now.strftime("%d"),
      'hour'   => now.strftime("%H"),
      'minute' => now.strftime("%I")
    }
    assert_date_value datum, date_time_string, 'When using a hash'

    datum.value = now
    assert_date_value datum, date_time_string, 'When using a real date'
  end

protected

  def assert_date_value(datum, should_return, message = '')
    datum.valid?
    assert_equal should_return, datum.value.strftime("%Y-%m-%d %H:%I"), message
  end

  def test_set_value(datum, value, should_return, message = '')
    datum.value = value
    datum.valid?
    assert_equal should_return, datum.value, "Should work with attr_writer #{message}"

    datum['value'] = value
    datum.valid?
    assert_equal should_return, datum.value, "Should work with hash setter #{message}"

    datum.attributes['value'] = value
    datum.valid?
    assert_equal should_return, datum.value, "Should work with attributes hash setter #{message}"
  end

end