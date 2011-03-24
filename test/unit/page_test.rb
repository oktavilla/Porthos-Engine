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

  context 'A page with a one to one custom relationship' do
    setup do
      @field_set = Factory(:field_set)
      @field = Factory(:page_association_field, {
        :field_set => @field_set,
        :handle => 'related_page',
        :relationship => 'one_to_one'
      })
      @page = Factory(:page, :field_set => @field_set)
      @related_page = Factory(:page, :field_set => @field_set)
      @custom_association = Factory(:custom_association, {
        :field => @field,
        :context => @page,
        :target => @related_page,
        :handle => @field.handle
      })
    end

    should 'make the associated object availible by the handle' do
      assert @page.respond_to?(:related_page), "Should respond to related_page"
      assert_equal @related_page, @page.reload.related_page
    end
  end

  context 'A page with a one to many custom relationship' do
    setup do
      @field_set = Factory(:field_set)
      @field = Factory(:page_association_field, {
        :field_set => @field_set,
        :handle => 'related_pages',
        :relationship => 'one_to_many'
      })
      @page = Factory(:page, :field_set => @field_set)
      @related_pages = []
      3.times do
        related_page = Factory(:page, :field_set => @field_set)
        Factory(:custom_association, {
          :field => @field,
          :context => @page,
          :target => related_page,
          :handle => @field.handle,
          :relationship => 'one_to_many'
        })
        @related_pages << related_page
      end
    end

    should 'make the associated objects availible by the handle' do
      assert @page.respond_to?(:related_pages), "Should respond to related_page"
      assert_equal 3, @page.related_pages.size
      assert @page.related_pages.is_a?(Porthos::CustomAssociationProxy)
      assert_equal @related_pages, @page.related_pages.all
    end
  end
end