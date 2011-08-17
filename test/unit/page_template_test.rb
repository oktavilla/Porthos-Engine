require_relative '../test_helper'
class PageTemplateTest < ActiveSupport::TestCase

  setup do
    @page_template = Factory.build(:page_template, {
      :template_name => nil,
      :handle => 'bacon',
      :instruction_body => 'Le instruction'
    })
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

  test 'propagate shared attrbutes to items' do
    page = Page.from_template(@page_template, :title => 'Chunky')
    page.save
    assert_equal 'bacon', page.handle
    assert_equal 'Le instruction', page.instruction_body

    @page_template.instruction_id = Porthos::MongoMapper::Instruction.create(:body => 'Banana chunks is tasty').id
    @page_template.handle = 'bananas'
    @page_template.save

    page.send(:remove_instance_variable, :@instruction_body) # reset memoized variable
    page.reload
    assert_equal 'bananas', page.handle
    assert_equal 'Banana chunks is tasty', page.instruction_body
  end
end
