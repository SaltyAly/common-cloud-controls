@CCC.ObjStor @CCC.ObjStor.CN01 @PerService @object-storage @tlp-amber @tlp-red
Feature: CCC.ObjStor.CN01.AR01
  As a security administrator
  I want to prevent any requests to read protected buckets using untrusted KMS keys
  So that data encryption integrity and availability are protected against unauthorized encryption


  Background:
    Given a cloud api for "{config}" in "api"
    And I call "{api}" with "GetServiceAPI" using argument "object-storage"
    And I refer to "{result}" as "storage"

# Planned: requires objstorage.Service method ListObjectsWithKMSKey (bucket read parameterized by a KMS key)
@Planned
  Scenario: Service prevents reading bucket with an untrusted KMS key
    When I call "{storage}" with "ListObjectsWithKMSKey" using arguments "{resource-name}" and "{untrusted-kms-key}"
    Then "{result}" is an error
    And I attach "{result}" to the test output as "untrusted-kms-list-objects-error.txt"


# Planned: requires objstorage.Service method ListObjectsWithKMSKey (bucket read parameterized by a KMS key)
@Planned
  Scenario: Service allows reading bucket with the trusted KMS key
    When I call "{storage}" with "ListObjectsWithKMSKey" using arguments "{resource-name}" and "{trusted-kms-key}"
    Then "{result}" is not an error
    And I attach "{result}" to the test output as "trusted-kms-list-objects-result.json"
