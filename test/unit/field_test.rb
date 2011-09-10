require_relative '../test_helper'
class FieldTest < ActiveSupport::TestCase

  test 'building a field from a template' do
    field_template = Factory.build(:field_template)
    field = Field.from_template(field_template)
    assert field.kind_of?(Field)
    field_template.shared_attributes.each do |key, attribute|
      assert_equal attribute, field[key], "Should have mirrored the template attribute #{key}"
    end
    assert_equal field_template.id, field.datum_template_id
  end

  test 'type casting the value for a date' do
    field = Field.new(:input_type => 'date')

    field.input_type = 'date'
    field.value = '2000-01-01'
    field.valid? # Trigger type casting
    assert_equal Time, field.value.class
  end


  test 'type casting the value for a boolean' do
    field = Field.new(:input_type => 'boolean')

    ['1', 1, true, 'true', 't'].each do |bool|
      field.value = bool
      field.valid?
      assert_equal TrueClass, field.value.class, "#{bool} should get type cast to TrueClass"
    end

    ['0', 0, false, 'false', 'f'].each do |bool|
      field.value = bool
      field.valid?
      assert_equal FalseClass, field.value.class, "#{bool} should get type cast to FalseClass"
    end
  end

  test 'string field rendering settings' do
    field_template = Factory.build(:string_field_template)
    string_field = Field.from_template(field_template)

    assert string_field.respond_to?(:multiline)
    assert string_field.respond_to?(:allow_rich_text)
  end

end