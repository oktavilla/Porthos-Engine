require_relative '../test_helper'

class FieldSetTest < ActiveSupport::TestCase
  context "A field set" do
    setup do
      @field_set = Factory(:field_set)
    end
    subject { @field_set }

    should validate_presence_of :title
    should validate_presence_of :page_label
    should validate_presence_of :handle

    should validate_uniqueness_of(:title).case_insensitive
    should validate_uniqueness_of(:handle).case_insensitive

    should have_many(:fields).dependent(:destroy)

    should have_many(:pages).dependent(:destroy)

    should 'have one node restricted to pages#index' do
      show_node = Factory(:node, :controller => 'pages', :action => 'show', :field_set_id => @field_set.id)
      assert_nil @field_set.node
      index_node = Factory(:node, :controller => 'pages', :action => 'index', :field_set_id => @field_set.id)
      assert_equal index_node, @field_set.reload.node
    end
  end
end