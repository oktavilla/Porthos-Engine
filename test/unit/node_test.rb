require_relative '../test_helper'

class NodeTest < ActiveSupport::TestCase

  test "delegate status changes to resource if present" do
    item = FactoryGirl.build(:item)
    node = FactoryGirl.build(:node, resource: item, status: 1)

    item.expects :unpublish
    node.toggle!
    assert node.inactive?

    node.status = -1
    item.expects :publish
    node.toggle!
    assert node.hidden?
  end

  test "#destroy_children" do
    node = FactoryGirl.build :node

    child = stub resource: stub
    child.expects :destroy_resource
    child.expects :destroy_children
    child.expects :destroy

    node.stubs children: [child]

    node.destroy_children
  end
end
