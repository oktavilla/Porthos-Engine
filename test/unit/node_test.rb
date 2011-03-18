require_relative '../test_helper'

class NodeTest < ActiveSupport::TestCase
  context "A node" do
    setup do
      @node = Factory(:node)
    end
    subject { @node }

    should belong_to :resource

    should validate_presence_of :url
    should validate_uniqueness_of :url
    should validate_presence_of :controller
    should validate_presence_of :action
  end
end