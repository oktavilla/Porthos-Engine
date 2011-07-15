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

  test 'building from a DatumTemplate' do
    template = Factory.build(:rich_text_field_template)
    datum = Datum.from_template(template)

    assert datum.is_a?(StringField), 'Should be instantiated as the correct class'
    template.shared_attributes.each do |attribute, value|
      assert_equal template.send(attribute),  datum.send(attribute), "Should have copied the value for #{attribute}"
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

end