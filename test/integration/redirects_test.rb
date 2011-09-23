require_relative '../test_helper'

class RedirectsTest < ActiveSupport::IntegrationCase
  test 'getting redirected' do
    page_template = Factory(:hero_page_template)
    Factory(:node, {
      url: 'take-me-here',
      action: 'show',
      resource: Page.create_from_template(page_template, { title: 'Batman', published_on: (Time.now-3600) })
    })
    Redirect.create(path: '/my-redirect', target: '/take-me-here')

    visit '/my-redirect'
    assert_equal '/take-me-here', current_path, 'should get redirected to target'
  end
end