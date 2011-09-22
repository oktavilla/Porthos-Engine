require_relative '../../test_helper'

class RedirectsTest < ActiveSupport::IntegrationCase
  setup do
    @redirect = Redirect.create(:path => '/my-redirect', :target => '/woohoo')
    login!
    visit admin_redirects_path
  end

  test 'listing redirects' do
    assert page.has_content?('/my-redirect'), 'should see redirect'
  end

  test 'creating redirect' do
    click_link I18n.t('admin.redirects.index.new_redirect')
    fill_in 'redirect_path', :with => '/its-party-over-here'
    fill_in 'redirect_target', :with => '/paaaaaarty'
    click_button I18n.t(:save)
    assert page.has_content?(I18n.t(:saved, scope: [:app, :admin_redirects]))
  end

  test 'editing redirect' do
    within '#content' do
      click_link I18n.t(:edit)
    end
    fill_in 'redirect_path', :with => '/the-new'
    click_button I18n.t(:save)
    assert page.has_content?(I18n.t(:saved, scope: [:app, :admin_redirects]))
  end

  test 'deleting redirect' do
    within '#content' do
      click_link I18n.t(:destroy)
    end
    assert page.has_content?(I18n.t(:deleted, scope: [:app, :admin_redirects]))
  end
end
