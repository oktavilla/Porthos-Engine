require_relative '../test_helper'
class PageTemplateTest < ActiveSupport::TestCase

  setup do
    @page_template = Factory.build(:page_template, :template_name => nil)
  end

  test 'presence of label' do
    @page_template.label = nil
    assert !@page_template.valid?, 'should not be valid'
    assert_not_nil @page_template.errors[:label], 'should have errors on label'
  end

  test 'uniqueness of label' do
    @page_template.save
    page_template2 = Factory.build(:page_template, :label => @page_template.label)
    assert !page_template2.valid?, 'should not be valid'
    assert_not_nil page_template2.errors[:label], 'should have errors on label'
  end

  test "instantiating a template from the template_name" do
    assert_equal PageFileTemplate.default, @page_template.template, "Should get the default template if no handle specified"

    @page_template.send :remove_instance_variable, :@template
    @page_template.template_name = 'blog'
    assert_equal PageFileTemplate.new('blog'), @page_template.template, "Should have instantiated a page file template from the handle"
  end
end