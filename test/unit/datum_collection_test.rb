require_relative '../test_helper'

class DatumCollectionTest < ActiveSupport::TestCase

  setup do
    @template = FactoryGirl.build(:datum_collection_template)
    @datum_collection = Field.from_template(@template)
  end

  test 'building a content block from a template' do
    assert @datum_collection.is_a?(DatumCollection), "#{@datum_collection.class} should be a DatumCollection"
    @template.shared_attributes.each do |key, attribute|
      assert_equal attribute, @datum_collection[key], "Should have copied the shared attribute #{key} to the datum"
    end
  end

  test 'data is sorted by position' do
    page = FactoryGirl.build(:page)
    page.data << @datum_collection

    data1 = FactoryGirl.build(:string_field, :position => 3)
    data2 = FactoryGirl.build(:field_set, :position => 2)
    data3 = FactoryGirl.build(:text_field, :position => 1)

    @datum_collection.data = [data1, data2, data3]
    page.save

    assert_equal [data3, data2, data1], @datum_collection.data, "should have sorted data by position"
  end

  test 'returns pages from page associations' do
    page = FactoryGirl.build(:page)
    pages = []
    3.times do
      FactoryGirl.build(:page).tap do |p|
        pages << p
        @datum_collection.data << PageAssociation.new(:page => p)
      end
    end
    
    assert_equal pages.map(&:id), @datum_collection.page_ids
    
    assert_equal pages, @datum_collection.pages.all
    @datum_collection.data.last.active = false
    
    @datum_collection.send :remove_instance_variable, :@pages
    @datum_collection.send :remove_instance_variable, :@page_ids
    
    assert_equal 2, @datum_collection.pages.size, 'should not include inactive data'
  end

  test 'doesnt return page associations without a page' do
    @datum_collection.data << PageAssociation.new()
    assert_empty @datum_collection.pages

    @datum_collection.send :remove_instance_variable, :@pages
    @datum_collection.send :remove_instance_variable, :@page_ids

    @datum_collection.data << PageAssociation.new(:page => FactoryGirl.build(:page))
    assert_equal 1, @datum_collection.pages.size
  end

end
