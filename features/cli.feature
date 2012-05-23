Feature: Middleman Create Assetfile CLI

  Scenario: Create a new Assetfile
    Given I run `middleman init MY_PROJECT`
    Then the exit status should be 0
    When I cd to "MY_PROJECT"
    And I run `middleman assetfile`
    Then the exit status should be 0
    Then the following files should exist:
      | Assetfile |