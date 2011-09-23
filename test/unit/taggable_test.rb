require_relative '../test_helper'

class Thing
  include MongoMapper::Document
  plugin Porthos::MongoMapper::Plugins::Taggable::Plugin
  taggable
  key :name, String
end

class TaggableTest < ActiveSupport::TestCase
  setup do
    Porthos::MongoMapper::Plugins::Taggable.delimiter = ', '
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end

  test 'should be taggable with a array' do
    my_thing = Thing.new(:name => 'Box')
    my_thing.tag_names = %w(tag1 tag2)

    assert_equal 'tag1, tag2', my_thing.tag_names
    assert_equal 2, my_thing.tags.count
  end

  test 'should be taggable with a string' do
    my_thing = Thing.new(:name => 'Box')
    my_thing.tag_names = 'tag1, tag2, tag with spaces'

    assert_equal 'tag1, tag2, tag with spaces', my_thing.tag_names
    assert_equal 3, my_thing.tags.count
  end

  test 'should return tags as a string' do
    box = Thing.new(:name => 'Box', :tag_names => 'tag1, tag2')
    assert_equal "tag1, tag2", box.tag_names
  end

  test 'should be able to return instances by tag' do
    box = Thing.create(:name => 'Box', :tag_names => 'tag1, tag2')
    circle = Thing.create(:name => 'Circle', :tag_names => 'tag2, tag3')
    triangle = Thing.create(:name => 'Triangle', :tag_names => 'tag1, tag2, tag3')
    assert_equal [box, triangle], Thing.tagged_with(%w(tag1)).all
    assert_equal [triangle], Thing.tagged_with(%w(tag1 tag3)).all
  end

  test 'should return all tags' do
    box = Thing.create(:name => 'Box', :tag_names => 'tag1, tag2')
    circle = Thing.create(:name => 'Circle', :tag_names => 'tag2, tag3')
    triangle = Thing.create(:name => 'Triangle', :tag_names => 'tag1, tag2, tag3')
    assert_equal %w(tag1 tag2 tag3), Thing.all_tags.collect { |tag| tag.name }
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
    box = Thing.new(:name => 'Box', :tag_names => 'tag1, tag2')
    box.tag_names = 'tag3'

    assert_equal 'tag3', box.tag_names
  end

  test 'should be taggable by namespace and without namespace' do
    my_thing = Thing.new(:name => 'Box')
    my_thing.tank_tag_names = %w(part1 part2)
    my_thing.tag_names = %w(tag1 tag2)

    assert_equal 'part1, part2', my_thing.tank_tag_names
    assert_equal 'tag1, tag2', my_thing.tag_names
  end

  test 'should be able to return instances by namespaced tag' do
    box      = Thing.create(:name => 'Box', :tank_tag_names => 'tag1, tag2')
    circle   = Thing.create(:name => 'Circle', :tank_tag_names => 'tag2, tag3')
    triangle = Thing.create(:name => 'Triangle', :tank_tag_names => 'tag1, tag2, tag3')
    skull    = Thing.create(:name => 'Skull', :bone_tag_names => 'hip, leg, arm, tag1')

    assert_equal [box, triangle], Thing.tagged_with(%w(tag1), :namespace => 'tank').all
    assert_equal [triangle], Thing.tagged_with(%w(tag1 tag3), :namespace => 'tank').all
  end

  test 'should be able to return list of tags by namespace with count for model' do
    box      = Thing.create(:name => 'Box', :tank_tag_names => 'tag1, tag2')
    circle   = Thing.create(:name => 'Circle', :tank_tag_names => 'tag2')
    triangle = Thing.create(:name => 'Triangle', :tank_tag_names => 'tag1, tag2, tag3')
    skull    = Thing.create(:name => 'Skull', :bone_tag_names => 'hip, leg, arm, tag2')

    tags_by_count = Thing.tags_by_count(:namespace => 'tank')

    assert_equal 'tag2', tags_by_count.first.name
    assert_equal 3, tags_by_count.first.count
    assert_equal 'tag3', tags_by_count.last.name
    assert_equal 1, tags_by_count.last.count
  end

  test 'tagging with space as delimiter' do
    Porthos::MongoMapper::Plugins::Taggable.delimiter = ' '
    box = Thing.new(:name => 'Box', :tank_tag_names => 'tag1 tag2 "ta g3"')
    assert_equal '"ta g3" tag1 tag2', box.tank_tag_names
  end

end