Feature: Site settings
  In order to setup contact details for my web site 
  As one who is a admin user
  I want to manage the site settings for the porthos installation 

  Background:
    Given I am logged in

  Scenario: Adding a site setting
    Given I go to the admin site_settings page    
    And   I follow t"app.views.admin.site_settings.index.add_site_setting"
    Then  I should be on the admin site_setting new page 
    When  I fill in "contact_email" for "site_setting_name" 
    And   I fill in "my-email@example.com" for "site_setting_value" 
    And   I press t"save"
    Then  a site_setting should exist with name: "contact_email" 
    And   I should be on the admin site_settings page
    And   I should see "contact_email"
    And   I should see element ".flash"

  Scenario: Editing a site setting
    Given a site_setting exists with name: "contact_telephone", value: "+46 (0) 70 123 456 789"
    And   I go to the admin site_settings page    
    And   I follow t"edit"
    Then  I should be on the admin site_setting's edit page 
    When  I fill in "123123123" for "site_setting_value" 
    And   I press t"save"
    Then  I should be on the admin site_settings page
    And   I should see "123123123"
    And   I should see element ".flash"
    
  Scenario: Deleting a site setting
    Given a site_setting exists with name: "contact_telephone", value: "+46 (0) 70 123 456 789"
    And   I go to the admin site_settings page    
    And   I follow t"destroy"
    Then  I should not see "contact_telephone" 
    Then  I should see element ".flash"
