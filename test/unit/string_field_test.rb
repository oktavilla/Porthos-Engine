require_relative '../test_helper'
class StringFieldTest < ActiveSupport::TestCase

  test 'strips its value before validation' do
    string_field = Factory.build(:string_field, :value => ' I haz spaces? ')
    string_field.valid?
    assert_equal 'I haz spaces?', string_field.value
  end

end