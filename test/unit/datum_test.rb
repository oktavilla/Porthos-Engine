require_relative '../test_helper'

class DatumTest < ActiveSupport::TestCase

  test 'uniqueness of handle within collection' do
    parent = Factory.build(:page, :data => [])
    Factory.build(:string_field, :handle => 'le_handle').tap do |datum|
      parent.data << datum
      assert datum.valid?, "datum should be valid"
    end

    Factory.build(:string_field, :handle => 'le_handle').tap do |datum|
      parent.data << datum
      assert !datum.valid?, "datum should not be valid"
      assert_not_nil datum.errors[:handle], "should have error on handle"
    end
  end

end