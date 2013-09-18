require_relative '../test_helper'

class ItemUpdaterTest < ActiveSupport::TestCase
  def setup
    @item = FactoryGirl.build :item
  end


  test "update item and node if node attributes is present" do
    attributes = { title: "hello", node: { name: "there" } }
    @item.expects(:update_attributes).with(title: "hello").returns true

    node = stub
    node.expects(:update_attributes).with name: "there"
    @item.stubs node: node

    ItemUpdater.new(@item, attributes).update
  end

  test "update item if node attributes if not present" do
    attributes = { title: "hello" }
    @item.expects(:update_attributes).with(title: "hello").returns true

    ItemUpdater.new(@item, attributes).update
  end
end
