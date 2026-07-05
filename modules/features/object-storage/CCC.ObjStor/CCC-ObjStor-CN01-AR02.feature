@CCC.ObjStor @CCC.ObjStor.CN01 @PerService @object-storage @tlp-amber @tlp-red
Feature: CCC.ObjStor.CN01.AR02
  As a security administrator
  I want to prevent any requests to read protected objects using untrusted KMS keys
  So that data encryption integrity and availability are protected against unauthorized encryption


  Background:
    Given a cloud api for "{config}" in "api"
    And I call "{api}" with "GetServiceAPI" using argument "object-storage"
    And I refer to "{result}" as "storage"
    And I call "{storage}" with "CreateObject" using arguments "{resource-name}", "test-object={timestamp}.txt", and "test content"
    And "{result}" is not an error

# Planned: requires objstorage.Service method ReadObjectWithKMSKey (object read parameterized by a KMS key)
@Planned
  Scenario: Service prevents reading object with an untrusted KMS key
    When I call "{storage}" with "ReadObjectWithKMSKey" using arguments "{resource-name}", "test-object={timestamp}.txt", and "{untrusted-kms-key}"
    Then "{result}" is an error
    And I attach "{result}" to the test output as "untrusted-kms-read-object-error.txt"


# Planned: requires objstorage.Service method ReadObjectWithKMSKey (object read parameterized by a KMS key)
@Planned
  Scenario: Service allows reading object with the trusted KMS key
    When I call "{storage}" with "ReadObjectWithKMSKey" using arguments "{resource-name}", "test-object={timestamp}.txt", and "{trusted-kms-key}"
    Then "{result}" is not an error
    And I attach "{result}" to the test output as "trusted-kms-read-object-result.json"
