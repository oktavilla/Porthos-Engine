require_relative '../test_helper'

class CustomAssociationTest < ActiveSupport::TestCase
  context "A custom association" do
    setup do
      @field_set = Factory(:field_set)
      @field   = Factory(:field, :field_set => @field_set)
      @context = Factory(:page, :field_set => @field_set)
      @target  = Factory(:page, :field_set => @field_set)
      @custom_association = Factory(:custom_association, {
        :field => @field,
        :context => @context,
        :target => @target
      })
    end
    subject { @custom_association }

    should belong_to :context
    should belong_to :target
    should belong_to :field

    should validate_presence_of :target_id
    should validate_presence_of :field_id
    should validate_presence_of :handle
    should validate_presence_of :relationship

    should parameterize_attribute :handle
  end
end