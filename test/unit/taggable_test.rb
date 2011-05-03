require_relative '../test_helper'

class Thing
  include MongoMapper::Document
  include Porthos::Taggable
  key :name, String
end

class TaggableTest < ActiveSupport::TestCase
  setup do
    Porthos::Tag.delimiter = ', '
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end

  test 'should be taggable with a array' do
    my_thing = Thing.create(:name => 'Box')
    my_thing.tag_names = %w(tag1 tag2)
    my_thing.save
    my_thing.reload
    assert_equal ['tag1', 'tag2'], my_thing.tags
  end

  test 'should be taggable with a string' do
    my_thing = Thing.create(:name => 'Box')
    my_thing.tag_names = 'tag1, tag2, tag with spaces'
    my_thing.save
    my_thing.reload
    assert_equal ['tag1', 'tag2', 'tag with spaces'], my_thing.tags
  end

  test 'should return tags as a string' do
    box = Thing.create(:name => 'Box', :tag_names => 'tag1, tag2')
    assert_equal "tag1, tag2", box.tag_names
  end

  test 'should be able to return instances by tag' do
    box = Thing.create(:name => 'Box', :tag_names => 'tag1, tag2')
    circle = Thing.create(:name => 'Circle', :tag_names => 'tag2, tag3')
    triangle = Thing.create(:name => 'Triangle', :tag_names => 'tag1, tag2, tag3')
    assert_equal [box, triangle], Thing.tagged_with(%w(tag1)).all
    assert_equal [triangle], Thing.tagged_with(%w(tag1 tag3)).all
  end

  test 'should be able to return list of tags with count for model' do
    box = Thing.create(:name => 'Box', :tag_names => 'tag1, tag2')
    circle = Thing.create(:name => 'Circle', :tag_names => 'tag2')
    triangle = Thing.create(:name => 'Triangle', :tag_names => 'tag1, tag2, tag3')
    tags_by_count = Thing.tags_by_count
    assert_equal 'tag2', tags_by_count.first.name
    assert_equal 3, tags_by_count.first.count
    assert_equal 'tag3', tags_by_count.last.name
    assert_equal 1, tags_by_count.last.count
  end

  test 'should be able to update tags' do
    box = Thing.create(:name => 'Box', :tag_names => 'tag1, tag2')
    box.reload
    box.update_attributes(:name => 'Boxy', :tag_names => 'tag3')
    box.reload
    assert_equal 'tag3', box.tag_names
  end
end
