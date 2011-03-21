require_relative '../test_helper'

class FieldTest < ActiveSupport::TestCase
  context "A field" do
    setup do
      @field = Factory(:field)
    end
    subject { @field }

    should have_many(:custom_attributes).dependent(:destroy)
    should have_many(:custom_associations).dependent(:destroy)

    should validate_uniqueness_of(:label).scoped_to(:field_set_id)
    should validate_uniqueness_of(:handle).scoped_to(:field_set_id)

    should validate_presence_of :field_set_id
    should validate_presence_of :label
    should validate_presence_of :handle

    should 'parameterize handle' do
      handle = 'A New Handle'
      @field.update_attributes(:handle => handle)
      assert_equal handle.parameterize, @field.handle
    end

    should 'not allow handles that is currently methods on a Page object' do
      @field.handle = Page.new.public_methods.first.to_s
      assert !@field.valid?
      assert @field.errors[:handle].any?
    end
  end
end