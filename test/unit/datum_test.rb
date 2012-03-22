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

  test "delegates updated_at to its root document" do
    page = Factory.create(:page, :data => [])
    child = Factory.build(:string_field)
    page.data << child

    page.updated_at = Time.local(2000, 1, 1)

    assert_equal Time.local(2000, 1, 1), child.updated_at
  end

  test 'uses the root document and its timestamp for its cache key' do
    page = Factory.create(:page, :data => [])
    child = Factory.build(:string_field)
    page.data << child

    def child.id
      'lol'
    end
    def child.persisted?
      true
    end
    page.updated_at = Time.local(2000, 1, 1).utc
    
    assert_equal "StringField/lol-#{Time.local(2000, 1, 1).utc.to_s(:number)}/#{page.class.name}-#{page.id}", child.cache_key    
  end

end
