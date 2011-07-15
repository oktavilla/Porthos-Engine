require_relative '../test_helper'
class PageTemplateTest < ActiveSupport::TestCase

  setup do
    @page_template = Factory.build(:page_template, :template_name => nil, :handle => 'bacon')
  end

  test 'presence of label' do
    @page_template.label = nil
    refute @page_template.valid?, 'should not be valid'
    assert_not_nil @page_template.errors[:label], 'should have errors on label'
  end

  test 'uniqueness of label' do
    @page_template.save
    page_template2 = Factory.build(:page_template, :label => @page_template.label)
    refute page_template2.valid?, 'should not be valid'
    assert_not_nil page_template2.errors[:label], 'should have errors on label'
  end

  test 'instantiating a template from the template_name' do
    assert_nil @page_template.template_name
    assert_equal PageFileTemplate.default, @page_template.template, "Should get the default template if no handle specified"

    @page_template.send :remove_instance_variable, :@template
    @page_template.template_name = 'default'
    assert_equal PageFileTemplate.new('default'), @page_template.template, "Should have instantiated a page file template from the handle"
  end

  test 'propagate handle on update' do
    page = Page.from_template(@page_template, :title => 'Chunky')
    page.save
    @page_template.update_attributes(:handle => 'bananas')
    page.reload
    assert_equal 'bananas', page.handle
  end
end
