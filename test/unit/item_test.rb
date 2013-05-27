require_relative '../test_helper'

class ItemTest < ActiveSupport::TestCase
  setup do
    @item = FactoryGirl.build(:item)
  end

  should "have access to data values by their handles" do
    @item.data = [FactoryGirl.build(:string_field, :handle => 'short_description')]
    assert_equal @item.data.first, @item.data['short_description'], "Should return the datum by it's handle"
  end

  should 'require published_on to be less than now to be published' do
    @item.published_on = nil
    refute @item.published?

    @item.published_on = Date.today + 1.day
    refute @item.published?

    @item.published_on = Time.now - 1.minute
    assert @item.published?
  end

  should 'trim its title before validation' do
    @item.title = ' A title with spaces '
    @item.valid?
    assert_equal 'A title with spaces', @item.title
  end

  should "unpublish it self and inactivate associated node" do
    @item.published_on = Time.now
    @item.unpublish

    refute @item.published?
  end

  should "publish it self" do
    @item.published_on = nil
    @item.publish

    assert @item.published?
  end

  context "#toggle" do
    should "toggle itself if no node is present" do
      @item.published_on = nil
      @item.toggle!
      assert @item.published?

      @item.published_on = Time.current
      @item.toggle!
      refute @item.published?
    end

    should "delegate to node if present" do
      node = FactoryGirl.build(:node, status: -1, resource: @item)
      @item.stubs node: node

      node.expects(:toggle!)

      @item.toggle!
    end
  end
end
