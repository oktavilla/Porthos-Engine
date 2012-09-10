require_relative '../test_helper'

class RedirectsTest < ActiveSupport::IntegrationCase
  setup do
    page_template = FactoryGirl.create(:hero_page_template)
    FactoryGirl.create(:node, {
      url: 'take-me-here',
      action: 'show',
      resource: Page.create_from_template(page_template, { title: 'Batman', published_on: (Time.now-3600) })
    })
    Redirect.create(path: '/my-redirect', target: '/take-me-here')
  end

  test 'getting redirected' do
    Capybara.using_driver(:webkit) do
      visit '/my-redirect'
      assert_equal '/take-me-here', current_path, 'should get redirected to target'
    end
  end

  test 'ignores trailing slash' do
    Capybara.using_driver(:webkit) do
      visit '/my-redirect/'
      assert_equal '/take-me-here', current_path, 'should get redirected to target'
    end
  end
end
