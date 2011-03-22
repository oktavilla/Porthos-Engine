Then /^I should be logged out$/ do
  Given %{I go to the admin pages page}
  Then %{I should be on the login page}
end

Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  user = Factory(:user, {
    :login => login,
    :password => password,
    :password_confirmation => password
  })
end

Given /^I am logged in$/ do
  username    = 'admin'
  password = 'secretpass'
  Given %{I have one user "#{username}" with password "#{password}"}
  And %{I go to the login page}
  And %{I fill in "user_email" with "#{username}"}
  And %{I fill in "user_password" with "#{password}"}
  And %{I press "user_submit"}
end
