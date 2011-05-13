require_relative '../test_helper'

class ContentBlockTest < ActiveSupport::TestCase

  test 'building a content block from a template' do
    template = Factory.build(:content_block_template)
    content_block = Field.from_template(template)

    assert content_block.is_a?(ContentBlock), "#{content_block.class} should be a ContentBlock"
    assert_equal template.shared_attributes, content_block.attributes.except(:_id, :_type, :active, :data), "Shoul dhave copied the shared attributes to the datum"
  end

  test 'responds to data' do
    assert ContentBlock.new.respond_to?(:data)
  end

  test 'data is sorted by position' do
    page = Factory.build(:page)
    content_block = Factory.build(:content_block)
    page.data << content_block

    data1 = Factory.build(:string_field, :position => 3)
    data2 = Factory.build(:field_set, :position => 2)
    data3 = Factory.build(:text_field, :position => 1)

    content_block.data = [data1, data2, data3]
    page.save

    page2 = Page.find(page.id)

    assert_equal [data3, data2, data1].collect { |d| "#{d.position}: #{d.label}" }, content_block.data.collect { |d| "#{d.position}: #{d.label}" }, "should have sorted data by position"
  end

end