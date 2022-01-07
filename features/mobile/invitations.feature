@javascript @mobile
Feature: Invitations
  Background:
    Given following users exist:
      | username    | email             |
      | Alice Smith | alice@alice.alice |

  Scenario: Accepting an invitation
    Given I have been invited by "alice@alice.alice"
    And I am on my acceptance form page
    When I fill in the new user form
    And I press "Create account"
    And confirm the user "ohai"
    Then I should be on the new user session page
    And I sign in manually as "ohai" with password "secret" on the mobile website
    Then I should see the "welcome to diaspora" message
    And I should be able to friend "alice@alice.alice"
    When I select "Family" from "user_aspects" within "#hello-there"
    Then the aspect dropdown within "#hello-there" should be labeled "Family"
