require_relative '../../test_helper'

class SessionsTest < ActiveSupport::IntegrationCase
  test 'signing in' do
    login!
    assert_equal admin_root_path, current_path
    assert has_content?(I18n.t(:'authentication.signed_in')), "Expected to show flash message"
  end

  test 'signing out' do
    login!
    visit admin_logout_path
    assert_equal '/admin/login', current_path
    assert has_content?(I18n.t(:'authentication.signed_out')), "Expected to show flash message"
  end

  test 'login with invalid credentials' do
    visit '/admin/login'
    fill_in User.human_attribute_name('username'), :with => 'wrong'

    click_button I18n.t(:login, :scope => :'views.admin.sessions.new')

    assert_equal admin_login_path, current_path

    assert has_content?(I18n.t(:'authentication.failed')), "Expected to show flash message"
  end

end
