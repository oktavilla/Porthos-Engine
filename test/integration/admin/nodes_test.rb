require_relative '../../test_helper'

class NodesTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @page_template = FactoryGirl.create(:page_template, :allow_node_placements => true)
    @root_node = FactoryGirl.create(:root_node, :handle => @page_template.handle)
  end

  test 'adding a node pointing to a page' do
    new_page = FactoryGirl.create(:page, :page_template => @page_template, :published_on => nil)
    visit admin_item_path(new_page)
    click_link I18n.t(:'admin.items.details.publish_now')
    assert_equal new_admin_node_path, current_path
    fill_in 'node_name', :with => 'My page'
    fill_in 'node_slug', :with => 'my-page'
    choose('not_shown_in_nav')
    choose("node_parent_id_#{@root_node.id}")
    click_button I18n.t(:save)
    assert page.find(".navigation").has_content?('My page'), 'Should see node whitin nodes list'
  end

  test 'adding a node pointing to a page template' do
    page_template = FactoryGirl.create(:page_template, :allow_node_placements => false)
    new_section = FactoryGirl.create(:section, :page_template_id => page_template.id, :published_on => 1.day.ago)
    visit new_admin_node_path
    fill_in 'node_name', with: 'My section'
    fill_in 'node_slug', with: 'my-section'
    fill_in 'node_controller', with: 'pages'
    fill_in 'node_action', with: 'index'
    select page_template.label, from: 'node_handle'
    choose('not_shown_in_nav')
    choose("node_parent_id_#{@root_node.id}")
    click_button I18n.t(:save)


    assert page.find("#nodes li").has_content?('My section'), 'Should see node whitin nodes list'
    within "#nodes" do
      click_link I18n.t('show_all')
    end
    assert_equal admin_items_url(with_page_template: page_template.id), current_url
  end

  test 'listing nodes' do
    new_node = create_node
    visit admin_nodes_path
    assert page.find("#root").has_content?('Start')
    assert page.find("#nodes li").has_content?(new_node.name)
  end

  test 'editing a node' do
    new_node = create_node
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
    node = create_node
    child_node = create_node(:parent => node, :name => "The child node")

    visit admin_nodes_path

    within("#node_#{node.id}") do
      click_link I18n.t(:destroy)
    end

    refute page.find("#content").has_content?(node.name)
  end

  test "deleting a node with child nodes and pages" do
    parent_page = FactoryGirl.create :page, page_template: @page_template, title: "My page"
    parent_node = create_node controller: "pages", action: "show", resource: parent_page, name: "My node"
    child_page = FactoryGirl.create :page, page_template: @page_template, title: "Child page"
    child_node = create_node controller: "pages", action: "show", resource: child_page, name: "Child node", parent: parent_node

    visit admin_item_path parent_page

    within ".header" do
      click_link I18n.t(:destroy)
    end

    assert_equal confirm_delete_admin_node_path(parent_node), current_path

    within "#content" do
      assert page.has_content? "My node"
      assert page.has_content? "Child node"
    end

    click_button I18n.t("admin.nodes.confirm_delete.commit")

    assert_equal admin_nodes_path, current_path
    assert has_flash_message? I18n.t("app.admin_nodes.deleted")
  end

  test 'toggling a node' do
    new_node = create_node status: -1
    visit admin_nodes_path
    within("#node_#{new_node.id}") do
      click_link I18n.t(:edit)
    end
    assert edit_admin_node_path(new_node), current_path

    click_button I18n.t("admin.nodes.edit.toggle_active")

    assert_equal edit_admin_node_path(new_node), current_path
    assert page.find("#sub_nav").has_content? I18n.t("admin.nodes.edit.hidden")
  end

  protected

  def create_node attrs = {}
    node_attrs = {
      :name => 'Node',
      :parent => @root_node,
      :controller => "controller",
      :action => "action"
    }.merge(attrs)

    FactoryGirl.create :node, node_attrs
  end

end
