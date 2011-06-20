require_relative '../../test_helper'
class UsersTest < ActiveSupport::IntegrationCase
  setup do
    login!
  end

  test 'adding a user' do
    create_user
    assert_equal admin_users_path, current_path
    assert has_flash_message?("Locutus Borg #{I18n.t(:'app.admin_general.saved')}")

    assert page.find('#userslist').has_content?('Locutus Borg'), 'Should display the user'
  end

  test 'updating a user' do
    create_user
    within '#userslist' do
      click_link I18n.t(:edit)
    end

    fill_in 'user_first_name', :with => 'Jean-Luc'
    fill_in 'user_last_name', :with => 'Picard'

    click_button I18n.t(:save)

    assert has_flash_message?("Jean-Luc Picard #{I18n.t(:'app.admin_general.saved')}")
    assert page.find('#userslist').has_content?('Jean-Luc Picard'), 'Should display the user'
  end

  test 'deleting a user' do
    user = Factory.create(:user, :first_name => 'Dorkey', :last_name => 'Bork')
    visit admin_users_path

    within "#userslist #user_#{user.id}" do
      click_link I18n.t(:destroy)
    end

    assert has_flash_message?("Dorkey Bork #{I18n.t(:'app.admin_general.deleted')}")
    refute page.find('#userslist').has_content?(user.name), 'Should have removed the user'
  end

private

  def create_user
    within '#main_nav' do
      click_link I18n.t(:admins)
    end

    assert_equal admin_users_path, current_path

    within '.tools' do
      click_link I18n.t(:'admin.users.index.add')
    end

    fill_in 'user_first_name', :with => 'Locutus'
    fill_in 'user_last_name', :with => 'Borg'
    fill_in 'user_email', :with => 'the-captain@strafleet.org'
    fill_in 'user_username', :with => 'locutus'
    fill_in 'user_password', :with => 'this-far-no-further'
    fill_in 'user_password_confirmation', :with => 'this-far-no-further'
    fill_in 'user_phone', :with => '000000'
    fill_in 'user_cell_phone', :with => '111111'

    click_button I18n.t(:save)
  end

end