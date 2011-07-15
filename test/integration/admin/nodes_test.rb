require_relative '../../test_helper'

class NodesTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @page_template = Factory(:page_template, :allow_node_placements => true)
    @root_node = Factory(:root_node, :handle => @page_template.handle)
  end

  test 'adding a node pointing to a page' do
    new_page = Factory(:page, :page_template => @page_template)
    visit admin_page_path(new_page)
    click_link I18n.t(:'admin.pages.show.publish_now')
    assert_equal new_admin_node_path, current_path
    fill_in 'node_name', :with => 'My page'
    fill_in 'node_url', :with => 'my-page'
    choose('not_shown_in_nav')
    choose("node_parent_id_#{@root_node.id}")
    click_button I18n.t(:save)
    assert page.find("#nodes li").has_content?('My page'), 'Should see node whitin nodes list'
  end

  test 'adding a node pointing to a section' do
    page_template = Factory(:page_template, :allow_node_placements => false)
    new_section = Factory(:section, :page_template_id => page_template.id)
    visit admin_page_path(new_section)
    click_link I18n.t(:'admin.pages.show.publish_now')
    assert_equal new_admin_node_path, current_path
    fill_in 'node_name', :with => 'My section'
    fill_in 'node_url', :with => 'my-section'
    choose('not_shown_in_nav')
    choose("node_parent_id_#{@root_node.id}")
    click_button I18n.t(:save)
    assert page.find("#nodes li").has_content?('My section'), 'Should see node whitin nodes list'
  end

  test 'listing nodes' do
    new_node = create_page_node
    visit admin_nodes_path
    assert page.find("#root").has_content?('Start')
    assert page.find("#nodes li").has_content?(new_node.name)
  end

  test 'editing a node' do
    new_node = create_page_node
    visit admin_nodes_path
    within("#node_#{new_node.id}") do
      click_link I18n.t(:edit)
    end
    assert edit_admin_node_path(new_node), current_path
    fill_in "node_name", :with => 'My updated node'
    click_button I18n.t(:save)
    assert_equal admin_nodes_path, current_path
    assert page.find("#nodes li").has_content?('My updated node'), "Should see node with updated name"
  end

  test 'deleting a node' do
    new_node = create_page_node
    visit admin_nodes_path
    within("#node_#{new_node.id}") do
      click_link I18n.t(:destroy)
    end
    refute page.find("#content").has_content?(new_node.name), "Should not see delete row name"
  end

protected

  def create_page_node
    Factory(:node, :name => 'Node',
      :parent => @root_node,
      :resource => Factory(:page, :page_template_id => @page_template.id))
  end

end