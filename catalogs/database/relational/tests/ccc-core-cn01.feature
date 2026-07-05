@CCC.Core.CN01
Feature: Data encryption in transit

"""
This feature ensures that end-to-end encryption of data in transit is leveraged and enforced
"""

@CCC.Core.CN01.TE01
Scenario: Verify that databases are enforcing encrypted connections
   Given an application attempting to connect to a database and the database is configured with some form of "require secure transport"
   When the connection attempt is made without using encryption
   Then the connection should be refused

@CCC.Core.CN01.TE02
Scenario: Verify all established connections to the database use encrypted transport
   Given one or more client connections have been established to the database
   When the database's active session metadata is queried for the encryption status of each connection
   Then every active connection should report an encrypted transport
   And no active connection should report an unencrypted transport
