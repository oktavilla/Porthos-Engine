require_relative '../test_helper'
class UserTest < ActiveSupport::TestCase

  setup do
    @user = FactoryGirl.build(:user, :username => 'foxie', :password => 'chunky!bacon', :password_confirmation => 'chunky!bacon')
  end

  test 'encrypts password' do
    assert @user.password_digest.present?, 'should have gotten a password_digest'
    assert BCrypt::Password.new(@user.password_digest) == 'chunky!bacon'
  end

  test 'authenticates and returns self' do
    assert_equal @user, @user.authenticate('chunky!bacon')
  end

  test 'rejecting faulty authentication' do
    assert_equal false, @user.authenticate('chunky-ham')
  end

  test 'find and authenticate' do
    @user.save
    assert_equal @user, User.authenticate('foxie', 'chunky!bacon'), 'should find the user and authenticate'
    refute User.authenticate('foxie', 'stale-bacon'), 'should find user but not authenticate'
    refute User.authenticate('rat', 'chunky!baloney')
  end

end