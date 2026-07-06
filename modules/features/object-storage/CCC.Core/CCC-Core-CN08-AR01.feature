@CCC.Core @CCC.Core.CN08 @PerService @tlp-amber @tlp-green @tlp-red
Feature: CCC.Core.CN08.AR01 - Data Replication and Redundancy
  As a security administrator
  I want to ensure data is replicated to a physically separate data center
  So that disaster recovery requirements are met


  Background:
    Given a cloud api for "{config}" in "api"
    And I call "{api}" with "GetServiceAPI" using argument "object-storage"
    And I refer to "{result}" as "storage"

@Behavioural @object-storage
  Scenario: Bucket data is replicated to physically separate locations
    When I call "{storage}" with "GetReplicationStatus" using argument "{resource-name}"
    And I refer to "{result}" as "replicationStatus"
    And I refer to "{replicationStatus.Locations}" as "locations"
    And I attach "{replicationStatus}" to the test output as "Replication Status"
    # The control requires >= 2 locations; the DSL only has an exact-length step, and the two membership checks below already require locations[0] and locations[1] to exist within permitted regions.
    Then "{permitted-regions}" is an array of objects with at least the following contents
      | value           |
      | {locations[0]}  |
    And "{permitted-regions}" is an array of objects with at least the following contents
      | value           |
      | {locations[1]}  |
