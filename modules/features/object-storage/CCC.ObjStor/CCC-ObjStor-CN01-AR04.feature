@CCC.ObjStor @CCC.ObjStor.CN01 @PerService @object-storage @tlp-amber @tlp-clear @tlp-green @tlp-red
Feature: CCC.ObjStor.CN01.AR04
  As a security administrator
  I want to prevent any requests to write to objects using untrusted KMS keys
  So that data encryption integrity and availability are protected against unauthorized encryption


  Background:
    Given a cloud api for "{config}" in "api"
    And I call "{api}" with "GetServiceAPI" using argument "object-storage"
    And I refer to "{result}" as "storage"
    And "{result}" is not an error

# Planned: requires objstorage.Service method CreateObjectWithKMSKey (object write parameterized by a KMS key)
@Planned
  Scenario: Service prevents writing object with an untrusted KMS key
    When I call "{storage}" with "CreateObjectWithKMSKey" using arguments "{resource-name}", "test-write-object={timestamp}.txt", "test content", and "{untrusted-kms-key}"
    Then "{result}" is an error
    And I attach "{result}" to the test output as "untrusted-kms-create-object-error.txt"


# Planned: requires objstorage.Service method CreateObjectWithKMSKey (object write parameterized by a KMS key)
@Planned
  Scenario: Service allows writing object with the trusted KMS key
    When I call "{storage}" with "CreateObjectWithKMSKey" using arguments "{resource-name}", "test-write-object={timestamp}.txt", "test content", and "{trusted-kms-key}"
    Then "{result}" is not an error
    And I attach "{result}" to the test output as "trusted-kms-create-object-result.json"
