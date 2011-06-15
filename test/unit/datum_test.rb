require_relative '../test_helper'

class DatumTest < ActiveSupport::TestCase

  test 'uniqueness of handle within collection' do
    parent = Factory.build(:page, :data => [])
    Factory.build(:string_field, :handle => 'le_handle').tap do |datum|
      parent.data << datum
      assert datum.valid?, "should be valid"
    end

    Factory.build(:date_field, :handle => 'le_handle').tap do |datum|
      parent.data << datum
      assert !datum.valid?, "should not be valid"
      assert_not_nil datum.errors[:handle], "should have errors on handle"
    end
  end

end