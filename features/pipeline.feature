Feature: Pipeline

  Scenario: Base Server
    Given the Server is running at "pipeline-app"
    When I go to "/assets/one_and_two.js"
    Then I should see "file1"
    And I should see "file2"
    When I go to "/assets/coffee.js"
    Then I should see "typeof"
  
  Scenario: Base Build
    Given a successfully built app at "pipeline-app"
    When I cd to "build"
    Then the following files should exist:
      | assets/one_and_two.js |
      | assets/coffee.js |
    And the file "assets/one_and_two.js" should contain "file1"
    And the file "assets/coffee.js" should contain "typeof"