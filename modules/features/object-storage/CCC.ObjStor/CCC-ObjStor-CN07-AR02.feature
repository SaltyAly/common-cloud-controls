@CCC.ObjStor @CCC.ObjStor.CN07 @PerService @object-storage @tlp-amber @tlp-clear @tlp-green @tlp-red
Feature: CCC.ObjStor.CN07.AR02
  As a security administrator
  I want deletion requests to be denied when MFA-delete protection is enabled and MFA is not satisfied
  So that objects are protected from accidental, unauthorized, or compromised-credential-based destruction


  Background:
    Given a cloud api for "{config}" in "api"
    And I call "{api}" with "GetServiceAPI" using argument "object-storage"
    And I refer to "{result}" as "storage"

# Planned: requires objstorage.Service method IsMFADeleteEnabled (report MFA-delete protection status for a bucket)
@Planned
  Scenario: Service denies object deletion without satisfied MFA when MFA-delete protection is enabled
    When I call "{storage}" with "IsMFADeleteEnabled" using argument "{resource-name}"
    Then "{result}" is true
    When I call "{storage}" with "CreateObject" using arguments "{resource-name}", "mfa-delete-test={timestamp}.txt", and "protected content"
    And "{result}" is not an error
    When I call "{storage}" with "DeleteObject" using arguments "{resource-name}" and "mfa-delete-test={timestamp}.txt"
    Then "{result}" is an error
    And I attach "{result}" to the test output as "mfa-delete-denied-error.txt"
