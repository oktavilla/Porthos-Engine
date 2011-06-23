require_relative '../test_helper'

class ContentBlockTest < ActiveSupport::TestCase

  setup do
    @template = Factory.build(:content_block_template)
    @content_block = Field.from_template(@template)
  end

  test 'building a content block from a template' do
    assert @content_block.is_a?(ContentBlock), "#{@content_block.class} should be a ContentBlock"
    assert_equal @template.shared_attributes, @content_block.attributes.except(:_id, :_type, :active, :data), "Shoul dhave copied the shared attributes to the datum"
  end

  test 'data is sorted by position' do
    page = Factory.build(:page)
    page.data << @content_block

    data1 = Factory.build(:string_field, :position => 3)
    data2 = Factory.build(:field_set, :position => 2)
    data3 = Factory.build(:text_field, :position => 1)

    @content_block.data = [data1, data2, data3]
    page.save

    assert_equal [data3, data2, data1], @content_block.data, "should have sorted data by position"
  end

  test 'returns pages from page associations' do
    page = Factory.build(:page)
    pages = []
    3.times do
      Factory.build(:page).tap do |p|
        pages << p
        @content_block.data << PageAssociation.new(:page => p)
      end
    end

    assert_equal pages, @content_block.pages
    @content_block.data.last.active = false
    @content_block.send :remove_instance_variable, :@pages
    assert_equal 2, @content_block.pages.size, 'should not include inactive data'
  end

  test 'doesnt return page associations without a page' do
    @content_block.data << PageAssociation.new()
    assert_empty @content_block.pages

    @content_block.send :remove_instance_variable, :@pages
    @content_block.data << PageAssociation.new(:page => Factory.build(:page))
    assert_equal 1, @content_block.pages.size
  end

end