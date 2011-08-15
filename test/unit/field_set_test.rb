require_relative '../test_helper'

class FieldSetTest < ActiveSupport::TestCase

  setup do
    @field_set_template = Factory.build(:field_set_template)
    @field_set = FieldSet.from_template(@field_set_template)
  end

  test 'sanity' do
    assert @field_set_template.content_template.datum_templates.any?
  end

  test 'mirrored the field_templates attributes' do
    assert_equal @field_set_template.label, @field_set.label, "Should have cloned the fields's label"
    assert_equal @field_set_template.handle, @field_set.handle, "Should have cloned the fields's handle"
    assert_equal @field_set_template.required?, @field_set.required?, "Should have cloned the fields's required?"
  end

  test 'created data from the datum templates' do
    @field_set_template.content_template.datum_templates.each do |field_template|
      @field_set.data[field_template.handle].tap do |datum|
        assert datum.kind_of?(Field), "Should have created fields from the field templates"
        field_template.shared_attributes.each do |key, attribute|
          assert_equal attribute, datum[key], "Should have mirrored the field_template attributes #{key} to the field"
        end
      end
    end
  end

  test 'finding data by their handle' do
    @field_set.data.each do |field|
      assert_equal field, @field_set.data[field.handle], "Should have found a field by it's handle"
    end
  end

  test 'updating data with an hash of attributes' do
    @field_set.data_attributes = {
      '0' => {
        id: @field_set.data.first.id,
        value: 'The truth may be out there, but the lies are inside your head.'
      }
    }

    assert_equal 'The truth may be out there, but the lies are inside your head.', @field_set.data.first.value, 'Should have set the value via an hash'
  end

  test 'updating data with an array of attributes' do
    @field_set.data_attributes = [{
      id: @field_set.data.first.id,
      value: 'If you put butter and salt on it, it tastes like salty butter.'
    }]

    assert_equal 'If you put butter and salt on it, it tastes like salty butter.', @field_set.data.first.value, 'Should have set the value via an hash'
  end

end