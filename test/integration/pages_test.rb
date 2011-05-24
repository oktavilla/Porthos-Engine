require_relative '../test_helper'
require 'launchy'
class PagesTest < ActiveSupport::IntegrationCase
  setup do
    stub_index_tank_put
    @page_template = Factory(:hero_page_template)
    @root_node = Factory(:root_node)
  end

  test 'rendering a page by url' do
    _page = create_page(:data => [ Factory.build(:string_field, :handle => 'description', :value => 'Lorem ipsum')])
    node = Factory(:node,
                   :url => 'my-page',
                   :action => 'show',
                   :resource_type => 'Page',
                   :resource_id => _page.id)

    visit '/my-page'

    assert page.find('body').has_content?('Lorem ipsum'), 'Should see description content'
  end

private
  def create_page(options = {})
    page = Page.from_template(@page_template, { :title => 'Batman', :uri => 'batman', :published_on => (Time.now-3600) }.merge(options))
    page.save
    page
  end
end
