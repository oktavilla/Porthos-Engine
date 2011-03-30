Feature: Redirects
  In order do redirects on my web Sites
  As one who is a admin user
  I want to setup and customize redirects

  Background:
    Given I am logged in

  Scenario: Adding a new redirect
    Given I go to the admin redirects pages
    And   I follow t"app.views.admin.redirects.index.add_redirect"
    Then  I should be on the admin redirect new page
    When  I fill in "/my-old-page" for "redirect_path"
    And   I fill in "/my-new-page" for "redirect_target"
    And   I press t"save"
    Then  I should be on the admin redirects page
    And   I should see "/my-old-page" within "table"
    And   I should see element ".flash"

  Scenario: Editing a redirect
    Given a redirect exists with path: "/old-article", target: "/new-article"
    And   I go to the admin redirects page
    And   I follow t"edit"
    Then  I should be on the admin redirect's edit page
    When  I fill in "/even-newer-post" for "redirect_target"
    And   press t"save"
    Then  I should be on the admin redirects pages
    And   I should see "/even-newer-post" within "table"
    And   I should see element ".flash"

  Scenario: Deleting a reiderct
    Given a redirect exists with path: "/old-article", target: "/new-article"
    And   I go to the admin redirects page
    And   I follow t"destroy"
    Then  I should be on the admin redirects pages
    And   I should not see "/even-newer-post" within "#content"
    And   I should see element ".flash"
