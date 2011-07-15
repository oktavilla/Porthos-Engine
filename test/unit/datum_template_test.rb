require_relative '../test_helper'
class DatumTemplateTest < ActiveSupport::TestCase

  should 'returns a Datum defined in the datum_class when to_datum is called' do
    @datum_template = Class.new(DatumTemplate) {
      def datum_class
        'StringField'
      end
    }.new
    assert_equal StringField, @datum_template.to_datum.class
  end

  should 'figure out the datum class' do
    module ::TestDatums
      class MyTestDatumTemplate < DatumTemplate
      end

      class MyTestDatum < Datum
      end
    end

    assert_equal TestDatums::MyTestDatum, TestDatums::MyTestDatumTemplate.new.datum_class.constantize
  end

  context 'when child to a page template' do
    should 'propagate created to pages data' do
      page_template = Factory.create(:page_template, :datum_templates => [])
      page = Page.create_from_template(page_template, :title => 'A story')

      template = Factory.build(:string_field_template, :handle => 'the_beginning', :label => 'Once upon a time')
      page_template.datum_templates << template
      page_template.save

      template.send :propagate_self
      page.reload

      assert_not_nil page.data['the_beginning']
      assert_equal template.label, page.data['the_beginning'].label
    end

    should 'propagate changes to pages datum' do
      page_template = Factory.create(:page_template, {
        :datum_templates => [Factory.build(:string_field_template, :handle => 'the_beginning', :label => 'Once upon a time')]
      })
      page = Page.create_from_template(page_template, :title => 'A story')

      page_template.datum_templates['the_beginning'].tap do |template|
        assert template.update_attribute(:label, '... in a galaxy somewhat close'), 'should save new beginning'
        template.send :propagate_updates
      end

      page.reload

      assert_equal '... in a galaxy somewhat close', page.data['the_beginning'].label
    end

    should 'propagate deletion to pages data' do
      page_template = Factory.create(:page_template)
      page = Page.create_from_template(page_template, :title => 'A story')

      template = page_template.datum_templates.first

      assert_equal template.label, page.data[template.handle].label

      assert template.destroy
      page.reload

      assert_nil page.data[template.handle], 'should have removed the datum matching the datum template'
    end
  end


  context 'when child to a content template' do
    setup do
      @content_template = Factory.create(:content_template, {
        datum_templates: [
          Factory.build(:string_field_template, {
            label: 'The string to rule them all',
            handle: 'the_string'
          })
        ]
      })
      @datum_template = @content_template.datum_templates.first
    end

    context 'when created' do
      setup do
        @page_template = Factory.create(:page_template, :datum_templates => [
          Factory.build(:field_set_template, {
            handle: 'a_field_set',
            content_template: @content_template
          })
        ])
        @page = Page.create_from_template(@page_template, title: 'A page')
      end

      should 'propagate to field sets directly under a page' do
        some_string = Factory.build(:string_field_template, {
          label: 'Just an ordinary string',
          handle: 'some_string'
        })
        @content_template.datum_templates << some_string
        @content_template.save
        some_string.send :propagate_self

        assert_equal 'Just an ordinary string', @page.reload.data['a_field_set'].data['some_string'].label
      end
    end

    context 'when updating' do
      should 'propagate to field sets directly under a page' do
        page_template = Factory.create(:page_template, :datum_templates => [
          Factory.build(:field_set_template, {
            handle: 'a_field_set',
            content_template: @content_template
          })
        ])
        page = Page.create_from_template(page_template, title: 'A page')

        assert_equal 'The string to rule them all', page.data['a_field_set'].data['the_string'].label, 'sanity'

        @datum_template.update_attribute :label, 'The string'
        @datum_template.send :propagate_updates

        assert_equal 'The string', page.reload.data['a_field_set'].data['the_string'].label, 'should have been updated'
      end

      should 'propagate to field sets under a content block' do
        page_template = Factory.create(:page_template, :datum_templates => [
          Factory.build(:datum_collection_template, {
            handle: 'a_datum_collection',
            content_templates_ids: [@content_template.id]
          })
        ])
        page = Page.create_from_template(page_template, title: 'A page')

        page.data['a_datum_collection'].data << @content_template.to_datum
        page.save

        assert_equal 'The string to rule them all', page.data['a_datum_collection'].data[0].data['the_string'].label, 'should have been updated'

        @datum_template.update_attribute :label, 'The string'
        @datum_template.send :propagate_updates

        assert_equal 'The string', page.reload.data['a_datum_collection'].data[0].data['the_string'].label, 'should have been updated'
      end
    end

    context 'when removing' do
      should 'propagate to field sets directly under a page' do
        page_template = Factory.create(:page_template, :datum_templates => [
          Factory.build(:field_set_template, {
            handle: 'a_field_set',
            content_template: @content_template
          })
        ])
        page = Page.create_from_template(page_template, title: 'A page')

        assert_equal 1, page.data['a_field_set'].data.size
        @datum_template.destroy

        assert_equal 0, page.data['a_field_set'].data.size
      end

      should 'propagate to field sets under a content block' do
        page_template = Factory.create(:page_template, :datum_templates => [
          Factory.build(:datum_collection_template, {
            handle: 'a_datum_collection',
            content_templates_ids: [@content_template.id]
          })
        ])
        page = Page.create_from_template(page_template, title: 'A page')

        page.data['a_datum_collection'].data << @content_template.to_datum
        page.save

        refute_nil page.data['a_datum_collection'].data[0].data['the_string'], 'should have the string datum'

        @datum_template.destroy

        assert_nil page.reload.data['a_datum_collection'].data[0].data['the_string'], 'should not have the string datum'
      end
    end
  end
end