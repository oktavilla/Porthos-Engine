require_relative '../test_helper'

class DatumTest < ActiveSupport::TestCase

  test 'uniqueness of handle within collection' do
    parent = Factory.build(:page, :data => [])
    Factory.build(:string_field, :handle => 'le_handle').tap do |datum|
      parent.data << datum
      assert datum.valid?, "datum should be valid"
    end

    Factory.build(:string_field, :handle => 'le_handle').tap do |datum|
      parent.data << datum
      refute datum.valid?, "datum should not be valid"
      assert_not_nil datum.errors[:handle], "should have error on handle"
    end
  end

  test 'building from a datum template' do
    template = Factory.build(:rich_text_field_template)
    datum = Datum.from_template(template)

    assert datum.is_a?(StringField), 'Should be instantiated as the correct class'
    template.shared_attributes.each do |key, attribute|
      assert_equal attribute,  datum[key], "Should have copied the value for #{key}"
    end
  end

  test "knowing it's parent datum that is a direct child to page" do
    page = Factory.build(:page, :data => [Factory.build(:datum_collection, :handle => 'article')])
    decendant = Factory.build(:string_field)
    page.data['article'].data << decendant

    assert_equal page.data['article'], decendant.root_embedded_document
  end

  test "knowing if it's a direct child to page" do
    page = Factory.build(:page, :data => [Factory.build(:datum_collection, :handle => 'article')])
    child = Factory.build(:string_field)
    decendant = Factory.build(:string_field)

    page.data << child
    page.data['article'].data << decendant

    assert child.is_root?
    refute decendant.is_root?
  end

  test "sets updated_at when created" do
    page = Factory.create(:page, :data => [Factory.build(:datum_collection, :handle => 'article')])
    child = Factory.build(:string_field)
    page.data << child

    assert child.updated_at.nil?, 'sanity check that updated_at is nil'

    page.save

    refute child.updated_at.nil?
    assert child.updated_at.is_a?(Time)
  end

  test "sets updated_at when using update attributes" do
    page = Factory.create(:page, :data => [Factory.build(:datum_collection, :handle => 'article')])
    child = Factory.build(:string_field)
    page.data << child
    page.save

    last_timestamp = child.updated_at
    last_cache_key = child.cache_key
    sleep(1) # mongomapper does not save milliseconds

    child.update_attributes(value: 'A value')

    refute_equal child.cache_key, last_cache_key, 'should have a new cache key'
    assert child.updated_at > last_timestamp, 'should have increased the updated_at'
  end

  test "does not update updated_at when parent is saved in another context" do
    page = Factory.create(:page, :data => [Factory.build(:datum_collection, :handle => 'article')])
    child = Factory.build(:string_field)
    page.data << child
    page.save

    last_timestamp = child.updated_at
    page.update_attributes(title: 'A new title')

    assert_equal last_timestamp, child.updated_at, 'should not have increased the updated_at'
  end

end