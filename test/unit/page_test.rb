require_relative '../test_helper'

class PageTest < ActiveSupport::TestCase
  context "A page" do
    setup do
      @page = Factory(:page)
    end
    subject { @page }

    should belong_to :field_set

    should have_many(:fields).through(:field_set)

    should 'delegate template to field set' do
      assert_equal @page.field_set.template, @page.template
    end

    should have_many(:custom_attributes).dependent(:destroy)

    should have_many(:custom_associations).dependent(:destroy)

    should have_many(:custom_association_contexts).dependent(:destroy)

    should have_one :node
    should have_one(:index_node).through(:field_set)
    should have_many(:contents).dependent(:destroy)

    should belong_to :created_by
    should belong_to :updated_by

    should have_many :comments

    should validate_presence_of :title
    should validate_presence_of :field_set_id

    should 'require published_on to be less than now to be published' do
      @page.published_on = nil
      assert !@page.published?
      @page.published_on = Date.today + 1.day
      assert !@page.published?
      @page.published_on = Time.now - 1.minute
      assert @page.published?
    end
  end

  context 'A page with custom attributes' do
    setup do
      @field_set = Factory(:field_set)
      @field = Factory(:string_field, :field_set => @field_set, :handle => 'field_handle_name')
      @page = Factory(:page, :field_set => @field_set)
      @custom_attribute = Factory(:string_attribute, {
        :field => @field,
        :context => @page,
        :handle => @field.handle,
        :value => 'The name of this page'
      })
    end

    should 'make custom attributes accessible by their handles' do
      assert @page.respond_to?(:field_handle_name)
      assert_equal @custom_attribute.value, @page.field_handle_name
      assert @page.respond_to?(:field_handle_name?)
      assert @page.field_handle_name?
    end

  end
end