require_relative '../test_helper'
require 'launchy'
class PublicPagesTest < ActiveSupport::IntegrationCase
  setup do
    WebMock.allow_net_connect!

    stub_index_tank_put
    @page_template = Factory(:hero_page_template)
    @root_node = Factory(:root_node)
  end

  test 'rendering a index node by url' do
    page1 = create_page(:data => [ Factory.build(:string_field, :handle => 'description', :value => 'Lorem ipsum')])
    page2 = create_page(:title => 'Spiderman', :data => [ Factory.build(:string_field, :handle => 'description', :value => 'Some other text')])

    node = Factory(:node, :url => 'posts', :page_template => @page_template)

    visit '/posts'

    assert page.find('body').has_content?('Batman'), 'Should see page1 title'
    assert page.find('body').has_content?('Spiderman'), 'Should see page2 title'
  end

  test 'rendering a page by url' do
    _page = create_page
    node = Factory(:node, {
      :url => 'my-page',
      :action => 'show',
      :resource_type => 'Page',
      :resource_id => _page.id
    })

    visit '/my-page'

    assert page.has_content?(_page.title), 'Should see the page title'
  end

private

  def create_page(options = {})
    Page.create_from_template(@page_template, { :title => 'Batman', :published_on => (Time.now-3600) }.merge(options))
  end

end