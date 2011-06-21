require_relative '../test_helper'

class PageTest < ActiveSupport::TestCase

  setup do
    @page_template = Factory.build(:page_template, :pages_sortable => false)
    @page = Page.from_template(@page_template, :title => 'A page')
  end

  should "created data from datum_templates" do
    @page_template.datum_templates.each do |datum_template|
      assert @page.data.one? { |datum| datum.handle == datum_template.handle }, "should have had a datum with handle #{datum_template.handle}"
    end
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