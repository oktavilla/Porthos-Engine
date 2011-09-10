Feature: Fields
  In order to setup field sets
  As one who is a admin user
  I want to manage the fields for a field set

  Background:
    Given I am logged in
    And   a field_set exists with title: "News", page_label: "Title", handle: "news", template_name: "blog"
    And   I go to the admin field_sets page    
    And   I follow "News"

  Scenario: Creating a field
    Given I follow t"app.views.admin.field_sets.show.add_field"
    Then  I should be on the admin field_set's new field page
    When  I fill in "News contents" for "field_label"
    And   I fill in "body" for "field_handle"
    And   I select "Sträng" from "field_type"
    And   I press t"save"
    Then  a field should exist
    And   I should be on the admin field_set's page
    And   I should see "News contents"
    And   I should see element ".flash"
    
  Scenario: Trying to add a field that already exists
    Given a field exists with field_set: field_set, label: "Author", handle: "author", type: "StringField"
    And   I follow t"app.views.admin.field_sets.show.add_field"
    Then  I should be on the admin field_set's new field page
    When  I fill in "Author" for "field_label"
    And   I fill in "author" for "field_handle"
    And   I select "Sträng" from "field_type"
    And   I press t"save"
    Then  I should see element ".error_messages" 

  Scenario: Editing an existing field
    Given a field exists with field_set: field_set, label: "Author", handle: "author", type: "StringField"
    And   I go to the admin field_set's page 
    And   I follow t"edit"
    Then  I should be on the admin field_set's field's edit page
    When  I fill in "Book author" for "field_label"
    And   I press t"save"
    Then  I should be on the admin field_set's page
    And   I should see "Book author"
    And   I should see element ".flash"

  Scenario: Deleting a field
    Given a field exists with field_set: field_set, label: "Author", handle: "author", type: "StringField"
    And   I go to the admin field_set's page 
    And   I follow t"destroy"
    Then  I should be on the admin field_set's page
    And   I should not see "Author" within "#content"
    And   I should see element ".flash"
