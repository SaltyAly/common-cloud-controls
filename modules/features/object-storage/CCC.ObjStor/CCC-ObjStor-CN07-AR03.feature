@CCC.ObjStor @CCC.ObjStor.CN07 @PerService @object-storage @tlp-amber @tlp-clear @tlp-green @tlp-red
Feature: CCC.ObjStor.CN07.AR03
  As a security administrator
  I want every object deletion attempt to be recorded in the audit logs
  So that deletion activity is fully auditable

# Each recorded deletion attempt must indicate whether MFA was required for the request.
# Each recorded deletion attempt must indicate whether MFA validation was satisfied for the request.
# The logging DSL's LogEntry does not yet expose MFA attributes, so neither outcome is independently
# assessable today; the scenario below verifies that deletion attempts are recorded in the audit logs.


  Background:
    Given a cloud api for "{config}" in "api"
    And I call "{api}" with "GetServiceAPI" using argument "object-storage"
    And I refer to "{result}" as "storage"
    And I call "{api}" with "GetServiceAPI" using argument "logging"
    And I refer to "{result}" as "loggingService"

@Behavioural
  Scenario: Object deletion attempts are recorded in the audit logs
    When I call "{storage}" with "CreateObject" using arguments "{resource-name}", "delete-audit-test={timestamp}.txt", and "audit trail content"
    Then "{result}" is not an error
    When I call "{storage}" with "DeleteObject" using arguments "{resource-name}" and "delete-audit-test={timestamp}.txt"
    And I attach "{result}" to the test output as "delete-attempt-result.txt"
    And we wait for a period of "10000" ms
    When I call "{loggingService}" with "QueryLogs" using arguments "{resource-name}", "data-write", and "{20}"
    Then "{result}" is not an error
    And I refer to "{result}" as "deletionLogs"
    And I attach "{deletionLogs}" to the test output as "Object Deletion Audit Logs"
    Then "{deletionLogs}" is an array of objects with at least the following contents
      | result    |
      | Succeeded |
