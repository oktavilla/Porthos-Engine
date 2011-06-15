require_relative '../test_helper'

class DatumTest < ActiveSupport::TestCase

  test 'uniqueness of handle within collection' do
    parent = Factory.build(:page, :data => [])
    Factory.build(:field, :handle => 'le_handle').tap do |datum|
      parent.data << datum
      assert datum.valid?
    end

    Factory.build(:field, :handle => 'le_handle').tap do |datum|
      parent.data << datum
      assert !datum.valid?
      assert_not_nil datum.errors.on(:handle)
    end
  end

end