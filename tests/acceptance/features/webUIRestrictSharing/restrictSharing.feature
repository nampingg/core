@webUI @insulated @disablePreviews @files_sharing-app-required
Feature: restrict Sharing
  As an admin
  I want to be able to restrict the sharing function
  So that users can only share files with specific users and groups

  Background:
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user0    |
      | user1    |
      | user2    |
    And these groups have been created:
      | groupname |
      | grp1      |
      | grp2      |
    And user "user0" has been added to group "grp1"
    And user "user1" has been added to group "grp1"
    And user "user2" has been added to group "grp2"
    And user "user0" has created folder "simple-folder"
    And user "user1" has created folder "simple-folder"
    And user "user1" has logged in using the webUI

  @TestAlsoOnExternalUserBackend
  @smokeTest
  Scenario: Restrict users to only share with users in their groups
    Given the setting "Restrict users to only share with users in their groups" in the section "Sharing" has been enabled
    When the user browses to the files page
    Then it should not be possible to share folder "simple-folder" with user "User Two" using the webUI
    When the user shares folder "simple-folder" with user "User Zero" using the webUI
    And the user re-logs in as "user0" using the webUI
    Then folder "simple-folder (2)" should be listed on the webUI

  @TestAlsoOnExternalUserBackend
  @smokeTest
  Scenario: Restrict users to only share with groups they are member of
    Given the setting "Restrict users to only share with groups they are member of" in the section "Sharing" has been enabled
    When the user browses to the files page
    Then it should not be possible to share folder "simple-folder" with group "grp2" using the webUI
    When the user shares folder "simple-folder" with group "grp1" using the webUI
    And the user re-logs in as "user0" using the webUI
    Then folder "simple-folder (2)" should be listed on the webUI

  @TestAlsoOnExternalUserBackend
  Scenario: Do not restrict users to only share with groups they are member of
    Given user "user3" has been created with default attributes and without skeleton files
    And user "user3" has been added to group "grp2"
    And user "user3" has created folder "simple-folder"
    And the setting "Restrict users to only share with groups they are member of" in the section "Sharing" has been disabled
    And the user browses to the files page
    When the user shares folder "simple-folder" with group "grp2" using the webUI
    And the user re-logs in as "user3" using the webUI
    Then folder "simple-folder (2)" should be listed on the webUI

  @TestAlsoOnExternalUserBackend
  @smokeTest
  Scenario: Forbid sharing with groups
    Given the setting "Allow sharing with groups" in the section "Sharing" has been disabled
    When the user browses to the files page
    Then it should not be possible to share folder "simple-folder" with group "grp1" using the webUI
    And it should not be possible to share folder "simple-folder" with group "grp2" using the webUI
    When the user shares folder "simple-folder" with user "User Zero" using the webUI
    And the user re-logs in as "user0" using the webUI
    Then folder "simple-folder (2)" should be listed on the webUI

  @skipOnOcV10.3
  Scenario: Editing share permission of existing share when sharing with groups is forbidden
    Given the user has shared folder "simple-folder" with group "grp1"
    And the setting "Allow sharing with groups" in the section "Sharing" has been disabled
    When the user opens the share dialog for folder "simple-folder"
    Then group "grp1" should be listed in the shared with list
    When the user sets the sharing permissions of group "grp1" for "simple-folder" using the webUI to
      | share | no |
    Then dialog should be displayed on the webUI
      | title               | content                      |
      | Error while sharing | Group sharing is not allowed |
    When the user reloads the current page of the webUI
    Then the following permissions are seen for "simple-folder" in the sharing dialog for group "grp1"
      | share | yes |

  @skipOnOcV10.3
  Scenario: Editing create permission of existing share when sharing with groups is forbidden
    Given the user has shared folder "simple-folder" with group "grp1"
    And the setting "Allow sharing with groups" in the section "Sharing" has been disabled
    When the user opens the share dialog for folder "simple-folder"
    Then group "grp1" should be listed in the shared with list
    When the user sets the sharing permissions of group "grp1" for "simple-folder" using the webUI to
      | create | no |
    Then dialog should be displayed on the webUI
      | title               | content                      |
      | Error while sharing | Group sharing is not allowed |
    When the user reloads the current page of the webUI
    Then the following permissions are seen for "simple-folder" in the sharing dialog for group "grp1"
      | create | yes |

  Scenario: Deleting group share when sharing with groups is forbidden
    Given the user has shared folder "simple-folder" with group "grp1"
    And the setting "Allow sharing with groups" in the section "Sharing" has been disabled
    When the user opens the share dialog for folder "simple-folder"
    Then group "grp1" should be listed in the shared with list
    When the user deletes share with group "grp1" for the current file
    Then group "grp1" should not be listed in the shared with list
