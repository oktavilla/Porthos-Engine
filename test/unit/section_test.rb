require_relative '../test_helper'

class SectionTest < ActiveSupport::TestCase
  setup do
    @section = FactoryGirl.build(:section)
  end

  should 'recursively find datum values for a key' do
    @section.data = [
      AssetAssociation.new(display_option_id: 9, active: true),
      DatumCollection.new({
        data: [
          PageAssociation.new(page_id: 2, active: true),
          AssetAssociation.new(display_option_id: 5, active: true),
          AssetAssociation.new(display_option_id: 7, active: false)
        ],
        active: true
      }),
      PageAssociation.new(page_id: 5, active: true),
      AssetAssociation.new(display_option_id: 1, active: true)
    ]

    assert_equal [9, 5, 1], @section.send(:recursive_find_in_datum, :display_option_id)
    assert_equal [2, 5], @section.send(:recursive_find_in_datum, :page_id)
  end

  should 'find association ids' do
    @section.expects(:recursive_find_in_datum).with(:page_id).returns ['lol']

    assert_equal ['lol'], @section.send(:find_association_ids)
  end

  should 'store association ids' do
    @section.stubs(find_association_ids: [2, 3])
    @section.run_callbacks :save

    assert_equal [2, 3], @section.association_ids
  end

  should 'find display option ids' do
    @section.expects(:recursive_find_in_datum).with(:display_option_id).returns ['haii']

    assert_equal ['haii'], @section.send(:find_display_option_ids)
  end

  should 'store display option ids' do
    @section.stubs(find_display_option_ids: [1, 5])
    @section.run_callbacks :save

    assert_equal [1, 5], @section.display_option_ids
  end

  context 'with associations to other items' do
    setup do
      @section.page_template = FactoryGirl.create :page_template
      @page = FactoryGirl.create(:page)
      @section.data << PageAssociation.new(page_id: @page.id, active: true)
    end

    should 'touch associated items' do
      @section.save
      @section.expects(:touch).once

      @page.update_attributes title: 'I am Void'
    end
  end
end
