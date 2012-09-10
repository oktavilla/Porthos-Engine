require_relative '../test_helper'
class LinkListTest < ActiveSupport::TestCase
  context 'LinkList' do
    setup do
      @link_list = LinkList.new(title: 'Some links in the footer', handle: 'footer_links')
    end

    should 'have timestamps' do
      assert @link_list.respond_to?(:updated_at)
    end

    should 'be valid with valid attributes' do
      assert @link_list.valid?
    end

    should 'create a title from the handle' do
      @link_list.title = nil
      @link_list.valid?
      assert_equal 'Footer links', @link_list.title
    end

    should 'not be valid without a handle' do
      @link_list.handle = nil
      refute @link_list.valid?
    end

    should 'sort links' do
      link1 = FactoryGirl.create(:link, :position => 2)
      link2 = FactoryGirl.create(:link, :position => 1)

      @link_list.links = [link1, link2]
      @link_list.save # trigger sort callback

      assert_equal [link2, link1], @link_list.links
    end

    context 'when finding by handle' do
      setup do
        @link_list.save
      end

      should 'find existing link lists' do
        assert_no_difference 'LinkList.count' do
          assert_equal @link_list, LinkList['footer_links']
        end
      end

      should 'create a new link lists' do
        assert_difference 'LinkList.count', +1 do
          list = LinkList['non_existant_list']
          assert_kind_of LinkList, list
        end
      end
    end
  end
end
