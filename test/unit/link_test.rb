require_relative '../test_helper'
class LinkTest < ActiveSupport::TestCase
  context 'Link' do
    setup do
      @link_list = LinkList.new(title: 'Footer links', handle: 'footer_links')
      @node = Factory.build(:node)
      @link = Factory.build(:link)
    end

    should 'be valid with valid attributes' do
      assert @link.valid?
    end

    should 'not be valid without title' do
      @link.title = nil
      refute @link.valid?
    end

    should 'not have valid without a node unless it has a url' do
      @link.node = nil
      @link.url = nil
      refute @link.valid?
      @link.url = '/some-url'
      assert @link.valid?
    end

    should 'not have valid without a url unless it has a node' do
      @link.node = nil
      @link.url = nil
      refute @link.valid?
      @link.node = @node
      assert @link.valid?
    end
  end
end