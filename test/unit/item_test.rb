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
end
