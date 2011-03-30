Feature: Finding pages
  In order to find different sorts of pages
  As one who is a admin user
  I want to be able to filter and search for pages

  Background:
    Given I am logged in
    And a field_set exists with title: "Article", page_label: "Title", handle: "default", template_name: "default"
    And a field_set exists with title: "Project", page_label: "Name", handle: "project", template_name: "default"
    And a page exists with field_set: first field_set, title: "About", slug: "about", tag_names: "article important"
    And a page exists with field_set: 2nd field_set, title: "Current projects", slug: "current-projects", tag_names: "important project"
    And I go to the admin pages listing page

  Scenario: Viewing the default page list
    Then I should see "Article" within "#sub_nav ul.filter"
    And I should see "Project" within "#sub_nav ul.filter"
    And I should see "About" within "#content"
    And I should see "important" within "ul.tags"

  Scenario: Listing pages by field set
    When I follow "Article" within "#sub_nav"
    Then I should see "About" within "#content"
    And I should not see "Current projects" within "#content"

  Scenario: Listing pages by tag
    When I follow "article" within "#sub_nav ul.tags"
    Then I should see "About" within "#content"
    And I should not see "Current projects" within "#content"

    When I follow "article" within "#sub_nav ul.tags"
    Then I should see "About" within "#content"
    And I should see "Current projects" within "#content"

    When I follow "important" within "#sub_nav ul.tags"
    Then I should see "About" within "#content"
    And I should see "Current projects" within "#content"

    When I follow "project" within "#sub_nav ul.tags"
    Then I should see "Current projects" within "#content"
    And I should not see "About" within "#content"
