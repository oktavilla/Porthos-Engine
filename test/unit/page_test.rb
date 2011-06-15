require_relative '../test_helper'

# Page (Built form PageTemple) has data ([Datum]) which can be
#   Field (built from FieldTemplate)
#   FieldSet (content?, built from FieldSetTemplate which has many field_templates)
#   ContentBlock (built from ContentBlockTemplate ||? DatumTemplate)
#
#   FieldSets have fields
#
#   ContentBlock has data which can be
#     Field
#     FieldSet
class PageTest < ActiveSupport::TestCase

  setup do
    @page_template = Factory.build(:page_template)
    @page = Page.from_template(@page_template)
  end

  test "data is created from datum_templates" do
    @page_template.datum_templates.each do |datum_template|
      assert @page.data.one? { |datum| datum.handle == datum_template.handle }, "should have had a datum with handle #{datum_template.handle}"
    end
  end

  test "accessing data values by their handles" do
    @page.data = [Factory.build(:string_field, :handle => 'short_description')]
    assert_equal @page.data.first, @page.data['short_description'], "Should return the datum by it's handle"
  end

  test 'published_on should be less than now to be published' do
    @page.published_on = nil
    assert !@page.published?
    @page.published_on = Date.today + 1.day
    assert !@page.published?
    @page.published_on = Time.now - 1.minute
    assert @page.published?
  end

  test 'trims its title before validation' do
    @page.title = ' A title with spaces '
    @page.valid?
    assert_equal 'A title with spaces', @page.title
  end

end