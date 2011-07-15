require_relative '../../test_helper'
class LinkListsTest < ActiveSupport::IntegrationCase
  setup do
    login!
    @link_list = LinkList['main']
  end

  test 'editing a link list' do
    visit_link_list
    within '.header' do
      click_link I18n.t(:edit)
    end

    fill_in 'link_list_title', :with => 'Main navigation'
    click_button I18n.t(:save)

    assert has_flash_message?(I18n.t(:'app.admin_general.saved'))
    assert page.find('.header').has_content?('Main navigation')
  end

  test 'adding a link to a remote location' do
    visit_link_list
    click_link I18n.t(:'admin.link_lists.show.new')

    fill_in 'link_title', :with => 'Our blog'
    fill_in 'link_url', :with => 'http://blog.ourdomain.org'
    click_button I18n.t(:save)

    assert has_flash_message?(I18n.t(:'app.admin_general.saved'))
    assert page.has_content?('Our blog')
  end

  test 'adding a link to a node' do
    node = Factory.create(:node, :name => 'Point me')

    visit_link_list
    click_link I18n.t(:'admin.link_lists.show.new')

    select node.name, :from => 'link_node_id'
    click_button I18n.t(:save)

    assert has_flash_message?(I18n.t(:'app.admin_general.saved'))
    assert page.has_content?(node.name)
  end

  test 'editing a link' do
    link = create_a_link
    visit_link_list
    within '#links' do
      click_link I18n.t(:edit)
    end

    fill_in 'link_title', :with => 'New title'
    click_button I18n.t(:save)
    assert has_flash_message?(I18n.t(:'app.admin_general.saved'))
    assert page.has_content?('New title')
  end

  test 'deleting a link' do
    create_a_link
    visit_link_list
    within '#links' do
      click_link I18n.t(:destroy)
    end

    assert has_flash_message?(I18n.t(:'app.admin_general.deleted'))
    refute page.has_content?('Some link')
  end

private

  def create_a_link(attrs = {})
    Factory.build(:link, { :title => 'Some link' }.merge(attrs)).tap do |link|
      @link_list.links << link
      @link_list.save
    end
  end

  def visit_link_list
    visit admin_nodes_path
    within '#sub_nav' do
      click_link @link_list.title
    end
  end

end