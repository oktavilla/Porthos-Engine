require_relative '../test_helper'

class PageTest < ActiveSupport::TestCase

  setup do
    @page_template = Factory.build(:page_template, :pages_sortable => false)
    @page = Page.from_template(@page_template, :title => 'A page')
  end

  should 'not be in list' do
    refute @page.in_list?
  end

  should 'not get a position' do
    assert @page.save
    assert_nil @page.position
  end

  should 'return nil for previous and next' do
    assert_nil @page.previous
    assert_nil @page.next
  end

  should "created data from datum_templates" do
    @page_template.datum_templates.each do |datum_template|
      assert @page.data.one? { |datum| datum.handle == datum_template.handle }, "should have had a datum with handle #{datum_template.handle}"
    end
  end

  should "have access to data values by their handles" do
    @page.data = [Factory.build(:string_field, :handle => 'short_description')]
    assert_equal @page.data.first, @page.data['short_description'], "Should return the datum by it's handle"
  end

  should 'require published_on to be less than now to be published' do
    @page.published_on = nil
    refute @page.published?

    @page.published_on = Date.today + 1.day
    refute @page.published?

    @page.published_on = Time.now - 1.minute
    assert @page.published?
  end

  should 'trim its title before validation' do
    @page.title = ' A title with spaces '
    @page.valid?
    assert_equal 'A title with spaces', @page.title
  end

  context 'when sortable' do
    setup do
      @page_template.update_attribute :pages_sortable, true
      @page.save
    end

    should 'be in list' do
      assert @page.in_list?, 'should be in list'
    end

    should 'get a position' do
      assert_equal 1, @page.position
    end

    context 'with siblings' do
      setup do
        @page2 = Page.create_from_template(@page_template, :title => 'Page 2')
      end

      should 'increment positions for new siblings' do
        assert_equal 2, @page2.position
      end

      should 'get previous' do
        assert_equal @page, @page2.previous
        assert_nil @page.previous
      end

      should 'get next' do
        assert_equal @page2, @page.next
        assert_nil @page2.next
      end
    end
  end
end