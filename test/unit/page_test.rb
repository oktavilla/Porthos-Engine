require_relative '../test_helper'

class PageTest < ActiveSupport::TestCase

  setup do
    @page_template = Factory.create(:page_template, :handle => 'super-awesome', :instruction_body => 'This is an instruction')
    @page = Page.from_template(@page_template, :title => 'A page')
  end

  should "created data from datum_templates" do
    @page_template.datum_templates.each do |datum_template|
      assert @page.data.one? { |datum| datum.handle == datum_template.handle }, "should have had a datum with handle #{datum_template.handle}"
    end
  end

  should 'not be sortable' do
    refute @page.sortable?
  end

  should 'not get a position' do
    assert @page.save
    assert_nil @page.position
  end

  should 'return nil for previous and next' do
    assert_nil @page.previous
    assert_nil @page.next
  end

  test 'should get handle' do
    @page.save
    assert_equal 'super-awesome', @page.handle
  end

  test 'should get instruction' do
    assert_equal 'This is an instruction', @page.instruction_body
  end

  context 'with a page template with a section' do
    should 'be access the section directly' do
      section = Factory.create(:section, page_template_id: @page_template.id)
      assert_equal section, @page.section
      assert_equal @page_template.section, @page.section
    end
  end

  context 'when sortable' do

    context 'using the position column' do
      setup do
        @page_template.update_attributes({
          sortable: :position.asc
        })
        @page.update_attributes(published_on: 1.week.ago)
      end

      should 'be sortable?' do
        assert @page.sortable?, 'should be sortable?'
      end

      should 'delegate sortable to page_template' do
        assert_equal :position.asc, @page.sortable
      end

      should 'get a position' do
        assert_equal 1, @page.position
      end

      context 'with siblings' do
        setup do
          @page2 = Page.create_from_template(@page_template, :title => 'Page 2', :published_on => 1.day.ago)
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

    context 'using the published_on column' do
      setup do
        @page_template.update_attributes({
          sortable: :published_on.desc
        })
        @page.update_attributes(published_on: 1.week.ago)
      end

      should 'not get a position' do
        refute @page.position.present?
      end

      context 'with siblings' do
        setup do
          @page2 = Page.create_from_template(@page_template, title: 'Page 2', published_on: 1.day.ago)
        end

        should 'get previous' do
          assert_equal @page2, @page.previous
          assert_nil @page2.previous
        end

        should 'get next' do
          assert_equal @page, @page2.next
          assert_nil @page.next
        end
      end
    end

  end
end