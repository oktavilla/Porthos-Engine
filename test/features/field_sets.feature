Feature: Field sets
  In order to create Pages
  As one who is a admin user
  I want to manage the field sets

  Background:
    Given I am logged in

  Scenario: Creating a new field set
    Given I go to the admin field_sets listing page    
    And   I follow t"app.views.admin.field_sets.index.new_field_set"
    Then  I should be on the admin field_set new page 
    When   I fill in "News" for "field_set_title"
    And   I fill in "Title" for "field_set_page_label"
    And   I fill in "news" for "field_set_handle"
    And   I select "Blog" from "field_set_template_name"
    And   I fill in "Current news page type" for "field_set_description"
    And   I press t"save"
    Then  a field_set should exist
    And   I should be on the admin field_set's page 
    And   I should see element ".flash"

  Scenario: Trying to create a field set with missing data
    Given I go to the admin field_set new page
    And   I fill in "news" for "field_set_handle"
    And   I select "Blog" from "field_set_template_name"
    And   I fill in "Current news page type" for "field_set_description"
    And   I press t"save"
    Then  I should see element ".error_messages" 

  Scenario: Editing a field set
    Given a field_set exists with title: "News", page_label: "Title", handle: "news", template_name: "blog"
    And   I go to the admin field_sets listing page    
    And   I follow "News"
    Then  I should be on the admin field_set's page 
    And   I follow t"app.views.admin.field_sets.show.edit"
    And   I should be on the admin field_set's edit page 
    When  I fill in "The latest news" for "field_set_title"
    And   I press t"save"
    Then  I should be on the admin field_set's page 
    Then  I should see "The latest news" within "h1"
    And   I should see element ".flash"

  Scenario: Deleting a field set
    Given a field_set exists with title: "News", page_label: "Title", handle: "news", template_name: "blog"
    And   I go to the admin field_sets listing page    
    And   I follow "News"
    Then  I should be on the admin field_set's page 
    And   I follow t"app.views.admin.field_sets.show.destroy"
    And   I should be on the admin field_sets listing page 
    And   I should see element ".flash"
