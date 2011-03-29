require_relative '../test_helper'

class ActsAsTaggableTest < ActiveSupport::TestCase
  context 'A model with acts as taggable' do
    setup do
      @page = Factory(:page)
      @tag_names = %w(tag1 tag2 tag3)
      @page.tag_names = @tag_names.join(Tag.delimiter)
    end
    subject { @page }

    should have_many(:taggings).dependent(:destroy)
    should have_many(:tags).through(:taggings)
    should have_many(:all_tags).through(:taggings)

    should 'have created tags from the tag_names string' do
      assert_equal @tag_names, @page.tags.collect(&:name)
    end

    should 'make the tags accesible as a string' do
      assert_equal @tag_names.join(Tag.delimiter), @page.tag_names
    end

    should 'parse tags from a string' do
      assert_equal ['tag1', 'tag2', 'tag 3'].sort, Page.tag_list_from_string('tag1 tag2 "tag 3"').sort
      Tag.delimiter = ','
      assert_equal ['tag1', 'tag2', 'tag 3'].sort, Page.tag_list_from_string('tag1, tag2, tag 3').sort
      Tag.delimiter = ' '
    end

    context 'with namespaces' do
      setup do
        @spaced_tag_names = %w(spaced_tag1 spaced_tag2 spaced_tag3)
        Page.instance_eval do
          acts_as_taggable :namespaces => ['spaced']
        end
      end

      should 'have a namespaced tag setter' do
        @page.spaced_tag_names = @spaced_tag_names.join(Tag.delimiter)
        assert_equal @spaced_tag_names, @page.all_tags.with_namespace('spaced').collect(&:name)
      end

      should 'have a namespaced tag getter' do
        assert_equal @spaced_tag_names.join(Tag.delimiter), @page.spaced_tag_names
      end
    end
  end
end