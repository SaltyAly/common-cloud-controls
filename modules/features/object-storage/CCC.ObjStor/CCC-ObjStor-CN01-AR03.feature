@CCC.ObjStor @CCC.ObjStor.CN01 @PerService @object-storage @tlp-amber @tlp-clear @tlp-green @tlp-red
Feature: CCC.ObjStor.CN01.AR03
  As a security administrator
  I want to prevent any requests to create buckets using untrusted KMS keys
  So that data encryption integrity and availability are protected against unauthorized encryption


  Background:
    Given a cloud api for "{config}" in "api"
    And I call "{api}" with "GetServiceAPI" using argument "object-storage"
    And I refer to "{result}" as "storage"

# Planned: requires objstorage.Service method CreateBucketWithKMSKey (bucket write parameterized by a KMS key)
@Planned
  Scenario: Service prevents writing bucket with an untrusted KMS key
    When I call "{storage}" with "CreateBucketWithKMSKey" using arguments "test-bucket-untrusted-kms" and "{untrusted-kms-key}"
    Then "{result}" is an error
    And I attach "{result}" to the test output as "untrusted-kms-create-bucket-error.txt"


# Planned: requires objstorage.Service method CreateBucketWithKMSKey (bucket write parameterized by a KMS key)
@Planned
  Scenario: Service allows writing bucket with the trusted KMS key
    When I call "{storage}" with "CreateBucketWithKMSKey" using arguments "test-bucket-trusted-kms" and "{trusted-kms-key}"
    Then "{result}" is not an error
    And I attach "{result}" to the test output as "trusted-kms-create-bucket-result.json"
    And I call "{storage}" with "DeleteBucket" using argument "{result.ID}"
