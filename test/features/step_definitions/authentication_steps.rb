Then /^I should be logged out$/ do
  Given %{I go to the admin pages page}
  Then %{I should be on the admin login page}
end

Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)"$/ do |login, password|
  user = Factory(:user, {
    :login => login,
    :password => password,
    :password_confirmation => password
  })
end

Given /^I am logged in$/ do
  username    = 'my_user'
  password = 'secretpass'
  Given %{I have one user "#{username}" with password "#{password}"}
  And %{I go to the admin login page}
  And %{I fill in "login" with "#{username}"}
  And %{I fill in "password" with "#{password}"}
  And %{I press "commit"}
  Then %{I should be on the admin root page}
end