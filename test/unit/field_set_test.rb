require_relative '../test_helper'

class FieldSetTest < ActiveSupport::TestCase

  test 'creating a field set from a field set template' do
    field_set_template = Factory.build(:field_set_template)
    field_set = FieldSet.from_template(field_set_template)

    assert_equal field_set_template.label, field_set.label, "Should have cloned the fields's label"
    assert_equal field_set_template.handle, field_set.handle, "Should have cloned the fields's handle"
    assert_equal field_set_template.required?, field_set.required?, "Should have cloned the fields's required?"

    field_set_template.field_templates.each do |field_template|
      field_set.data[field_template.handle].tap do |datum|
        assert datum.kind_of?(Field), "Should have created fields from the field templates"
        assert_equal field_template.shared_attributes, datum.attributes.except(:_id, :_type, :value, :active), "Should have mirrored the field_template attributes to the field"
      end
    end
  end

  test 'has many data' do
    assert FieldSet.new.respond_to?(:data)
  end

  test 'finding fields by their handle' do
    field_set = Factory.build(:field_set)
    field_set.data.each do |field|
      assert_equal field, field_set.data[field.handle], "Should have found a field by it's handle"
    end
  end

end