Feature: Tags
  In order to organize my contents
  As one who is admin user and manages a web site
  I want to manage and create tags

  Background:
    Given I am logged in

  Scenario: Adding a new tag
    Given I go to the admin tags page
    And   I follow t"app.views.admin.tags.index.add_tag"
    Then  I should be on the admin tag new page
    When  I fill in "color" for "tag_name"
    And   I press t"save"
    Then  I should be on the admin tags page
    And   I should see "color" within "table"
    And   I should see element ".flash"

  Scenario: Editing a tag
    Given a tag exists with name: "Green"
    And   I go to the admin tags page
    And   I follow t"edit"
    Then  I should be on the admin tag's edit page
    When  I fill in "lime-green" for "tag_name"
    And   I press t"save"
    Then  I should be on the admin tag's page
    And   I should see "lime-green" within "h1"
    And   I should see element ".flash"

  Scenario: Deleting a tag
    Given a tag exists with name: "Green"
    And   I go to the admin tags page
    And   I follow t"destroy"
    Then  I should be on the admin tags page
    And   I should not see "lime-green" within "#content"
    And   I should see element ".flash"

  Scenario: List stuff tagged by a tag
    Given a tag exists with name: "green"
    And   a field_set exists with title: "Article", page_label: "Title", handle: "article", template_name: "default"
    And   a page exists with title: "The color green", field_set: field_set, uri: "the-color-green", tag_names: "green"
    And   I go to the admin tags page
    And   I follow "green"
    Then  I should be on the admin tag's page
    And   I should see "The color green" within ".taggable"
