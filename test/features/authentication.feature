Feature: Authentication
  In order to use Porthos
  As one who is admin user
  I want to login.
  
  Scenario: Logging in with valid credentials
    Given I have one user "admin" with password "password"
    And   I go to the login page
    And   I fill in "user_username" with "admin"
    And   I fill in "user_password" with "password"
    And   I press "user_submit"
    Then  I should be on the admin pages page
    And   I should see element ".flash"
