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

  should 'find all association ids' do
    @item.data = [
      PageAssociation.new(:page_id => 1, :active => true),
      DatumCollection.new({
        :data => [
          PageAssociation.new(:page_id => 2, :active => true),
          PageAssociation.new(:page_id => 3, :active => false)
        ],
        :active => true
      }),
      PageAssociation.new(:page_id => 4, :active => true)
    ]
      
    assert_equal [1, 2, 4], @item.send(:find_association_ids)
  end

  context 'with associations to other items' do
    setup do
      @another_item = FactoryGirl.create(:item)
      @item.data << PageAssociation.new(:page_id => @another_item.id, :active => true)
    end

    should 'persist association ids' do
      assert_equal [], @item.association_ids
      @item.save
      assert_equal [@another_item.id], @item.association_ids
    end
     
    should 'touch associated items' do
      @item.save
      def @another_item.updated_at
        Time.local(2009, 8, 15, 14, 0, 0)
      end
      @another_item.update_attribute(:title, 'I am Void')
      assert_equal @another_item.updated_at, @item.reload.updated_at
    end
  end
end
