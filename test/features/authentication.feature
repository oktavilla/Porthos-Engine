Feature: Authentication
  In order to use Porthos
  As one who is admin user
  I want to use the authentication functionality.
  
  Scenario: Logging in with valid credentials
    Given I have one user "administrator" with password "password"
    And   I go to the admin login page
    And   I fill in "login" with "administrator"
    And   I fill in "password" with "password"
    And   I press "commit"
    Then  I should be on the admin root page
    
  Scenario: Logging in with invalid credentials
    Given I go to the admin login page
    And   I fill in "login" with "fake@email.com"
    And   I fill in "password" with "password"
    And   I press "commit"
    Then  I should be on the admin login page
    And   I should see element ".flash"
  
  Scenario: Logging out
    Given I am logged in
    And   I am on the admin root page
    And   I follow t"app.views.layouts.admin.account_nav.logout"
    Then  I should see element ".flash"
    Then  I should be logged out
