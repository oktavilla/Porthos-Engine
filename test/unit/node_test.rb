require_relative '../test_helper'

class NodeTest < ActiveSupport::TestCase
  context "A node" do
    setup do
      @node = Factory(:node)
    end
    subject { @node }

  end
end
