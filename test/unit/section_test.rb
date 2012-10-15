require_relative '../test_helper'

class SectionTest < ActiveSupport::TestCase
  setup do
    @section = FactoryGirl.build(:section)
  end

  should 'find all association ids' do
    @section.data = [
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

    assert_equal [1, 2, 4], @section.send(:find_association_ids)
  end

  context 'with associations to other items' do
    setup do
      @section.page_template = FactoryGirl.create :page_template
      @page = FactoryGirl.create(:page)
      def @page.updated_at
        Time.local(2009, 8, 15, 14, 0, 0)
      end
      @section.data << PageAssociation.new(:page_id => @page.id, :active => true)
    end

    should 'persist association ids' do
      assert_equal [], @section.association_ids
      @section.save
      assert_equal [@page.id], @section.association_ids
    end

    should 'touch associated items' do
      @section.save
      @section.expects(:touch).once

      @page.update_attribute(:title, 'I am Void')
    end
  end
end
