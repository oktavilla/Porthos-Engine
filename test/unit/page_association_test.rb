require_relative '../test_helper'
class PageAssociationTest < ActiveSupport::TestCase
  test "gets all pages except the root as targets" do
    pages = []
    2.times do
      pages << Factory(:page)
    end

    page = pages.first
    page_association = PageAssociation.new
    page.data << page_association

    assert_equal 1, page_association.targets.size
    assert !page_association.targets.include?(page)
  end

  test 'gets all pages except the root and siblings as targets when child to a content block' do
    pages = []
    4.times do
      pages << Factory(:page)
    end

    content_block = Factory(:content_block)
    pages[0].data << content_block
    page_association = PageAssociation.new(:page_id => pages[1].id)
    content_block.data << page_association
    content_block.data << PageAssociation.new(:page_id => pages[2].id)

    assert_equal 1, page_association.targets.size
    assert_equal pages[3], page_association.targets.first
  end
end