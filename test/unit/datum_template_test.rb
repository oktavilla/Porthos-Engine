require_relative '../test_helper'

class DatumTemplateTest < ActiveSupport::TestCase

  test 'to_datum returns a Datum defined in the datum_class method' do
    @datum_template = Class.new(DatumTemplate) {
      def datum_class
        'StringField'
      end
    }.new
    assert_equal StringField, @datum_template.to_datum.class
  end

  test 'figures out the datum class' do
    module ::TestDatums
      class MyTestDatumTemplate < DatumTemplate
      end

      class MyTestDatum < Datum
      end
    end

    assert_equal TestDatums::MyTestDatum, TestDatums::MyTestDatumTemplate.new.datum_class.constantize
  end

  test 'propagates created to pages data' do
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

  test 'propagates changes to pages datum' do
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

  test 'propagates deletion to pages data' do
    page_template = Factory.create(:page_template)
    page = Page.create_from_template(page_template, :title => 'A story')

    template = page_template.datum_templates.first

    assert_equal template.label, page.data[template.handle].label

    assert template.destroy
    page.reload

    assert_nil page.data[template.handle], 'should have removed the datum matching the datum template'
  end

end