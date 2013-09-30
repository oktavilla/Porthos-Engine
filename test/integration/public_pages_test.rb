require_relative '../test_helper'
require 'launchy'
class PublicPagesTest < ActiveSupport::IntegrationCase
  setup do
    Capybara.current_driver = :webkit
    @page_template = FactoryGirl.create(:hero_page_template)
    @root_node = FactoryGirl.create(:root_node)
  end

  teardown do
    Capybara.current_driver = nil
  end

  test 'rendering a index node by url' do
    page1 = create_page(:data => [ FactoryGirl.build(:string_field, :handle => 'description', :value => 'Lorem ipsum')])
    page2 = create_page(:title => 'Spiderman', :data => [ FactoryGirl.build(:string_field, :handle => 'description', :value => 'Some other text')])

    node = FactoryGirl.create(:node, :url => 'heroes', :handle => @page_template.handle)

    visit '/heroes'

    assert page.find('body').has_content?('Batman'), 'Should see page1 title'
    assert page.find('body').has_content?('Spiderman'), 'Should see page2 title'
  end

  test 'rendering a page by url' do
    _page = create_page
    node = FactoryGirl.create(:node, {
      :url => 'my-page',
      :action => 'show',
      :resource_type => 'Page',
      :resource_id => _page.id
    })

    visit '/my-page'

    assert page.has_content?(_page.title), 'Should see the page title'
  end

  test 'visiting a restricted page' do
    my_page = create_restricted_page
    visit "/batman"

    assert_equal admin_login_path, current_path
  end

  test 'visiting a restricted page when logged in' do
    my_page = create_restricted_page
    login!
    visit "/batman"

    assert_equal "/batman", current_path
  end

private

  def create_page(options = {})
    Page.create_from_template(@page_template, { :title => 'Batman', :published_on => (Time.now-3600) }.merge(options))
  end

  def create_restricted_page(options = {})
    create_page(options.merge(:restricted => true)).tap do |my_page|
      node = FactoryGirl.create(:node, {
        url: my_page.uri,
        controller: 'pages',
        action: 'show',
        resource: my_page
      })
    end
  end

end
