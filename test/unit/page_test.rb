require_relative '../test_helper'

class PageTest < ActiveSupport::TestCase

  setup do
    @page_template = FactoryGirl.create(:page_template, :handle => 'super_awesome', :instruction_body => 'This is an instruction')
    @page = Page.from_template(@page_template, :title => 'Page 1')
  end

  should 'delegate sortable?' do
    @page_template.sortable = :position.desc
    assert @page.sortable?, 'should be sortable?'
    @page_template.sortable = nil
    refute @page.sortable?
  end

  should 'delegate sortable to page_template' do
    @page_template.sortable = :position.asc
    assert_equal :position.asc, @page.sortable
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
    assert_equal 'super_awesome', @page.handle
  end

  test 'should get instruction' do
    assert_equal 'This is an instruction', @page.instruction_body
  end

  context 'with a page template with a section' do
    setup do
      @section = FactoryGirl.create(:section, page_template_id: @page_template.id)
    end

    should 'access the section directly' do
      assert_equal @section, @page.section
      assert_equal @page_template.section, @page.section
    end
  end

  context 'when sortable' do
    setup do
      @now = Time.now
      @page_template.update_attributes({
        sortable: :position.asc
      })
      @page.published_on = (@now - 1.day)
      @page.save
      @pages = [@page]
      4.times do |i|
         @pages << Page.create_from_template(@page_template, :title => "Page #{i+2}", :published_on => (@now - (i+2).days))
      end
    end

    context 'using the position column' do
      should 'get positions' do
        5.times do |i|
          assert_equal i+1, @pages[i].position, "#{@pages[i].title} should have gotten position #{i+1}"
        end
      end

      should 'work with previous' do
        assert_nil @pages[0].previous
        4.times do |i|
          assert_equal @pages[i], @pages[i+1].previous,  "#{@pages[i+1].title} previous should be #{@pages[i].title}"
        end
      end

      should 'get next' do
        4.times do |i|
          assert_equal @pages[i+1], @pages[i].next
        end
        assert_nil @pages[4].next
      end
    end

    context 'using the published_on column' do
      setup do
        @page_template.update_attributes({
          sortable: :published_on.desc
        })
      end

      should 'get previous' do
        assert_nil @pages[0].previous
        4.times do |i|
          assert_equal @pages[i], @pages[i+1].previous,  "#{@pages[i+1].title} previous should be #{@pages[i].title} but was #{@pages[i+1].previous.title}"
        end
      end

      should 'get next' do
        4.times do |i|
          assert_equal @pages[i+1], @pages[i].next
        end
        assert_nil @pages[4].next
      end
    end

    context 'when used with a category' do
      setup do
          @page_template.update_attributes({
          sortable: :position.asc,
          allow_categories: true
        })

        [0, 2, 3].each do |i|
          @pages[i].update_attributes(:"#{@page_template.handle}_tag_names" => '"The Category"')
        end
      end

      should 'get next within category' do
        assert_equal @pages[2], @pages[0].next_in_category
        assert_equal @pages[3], @pages[2].next_in_category
        assert_nil   @pages[3].next_in_category
      end

      should 'get previous within category' do
        assert_nil   @pages[0].previous_in_category
        assert_equal @pages[0], @pages[2].previous_in_category
        assert_equal @pages[2], @pages[3].previous_in_category
      end
    end

  end
end
