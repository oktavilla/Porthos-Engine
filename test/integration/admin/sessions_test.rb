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

  test 'login with remember me' do
    FactoryGirl.create(:user, {
      :username => 'a-user',
      :password => 'password',
      :password_confirmation => 'password' })
    visit admin_login_path
    fill_in User.human_attribute_name('username'), :with => 'a-user'
    fill_in User.human_attribute_name('password'), :with => 'password'
    check 'remember_me'
    click_button I18n.t(:'admin.sessions.new.login')

    assert_equal admin_root_path, current_path

    delete_cookie Rails.application.config.session_options[:key]

    visit admin_root_path
    assert_equal admin_root_path, current_path, 'should be signed in again'
  end

  test 'login with invalid credentials' do
    logout!
    visit admin_login_path

    fill_in User.human_attribute_name('username'), :with => 'wrong'

    click_button I18n.t(:'admin.sessions.new.login')

    assert has_content?(I18n.t(:'admin.sessions.failed')), "Expected to show failure flash message"

    visit admin_root_path
    assert_equal admin_login_path, current_path
  end

  test 'visiting the admin root when signed in' do
    login!
    visit admin_sessions_path

    assert_equal admin_root_path, current_path
  end

  test 'visiting the admin root when not signed in' do
    visit admin_root_path

    assert_equal admin_login_path, current_path, 'should not be signed in'
  end
end
