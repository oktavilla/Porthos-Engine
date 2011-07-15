require_relative '../../test_helper'

class SessionsTest < ActiveSupport::IntegrationCase
  test 'signing in' do
    login!
    assert_equal admin_root_path, current_path
    assert has_content?(I18n.t(:'admin.sessions.signed_in')), "Expected to show flash message"
  end

  test 'signing out' do
    login!
    logout!
    assert_equal '/admin/login', current_path
    assert has_content?(I18n.t(:'admin.sessions.signed_out')), "Expected to show flash message"
  end

  test 'login with invalid credentials' do
    visit admin_login_path
    fill_in User.human_attribute_name('username'), :with => 'wrong'

    click_button I18n.t(:'admin.sessions.new.login')

    assert_equal admin_login_path, current_path

    assert has_content?(I18n.t(:'admin.sessions.failed')), "Expected to show flash message"
  end

  test 'visinging the index action when signed in' do
    login!
    visit admin_sessions_path

    assert_equal admin_root_path, current_path
  end

end
