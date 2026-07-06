@CCC.RDMS.CN04.AR01
Feature: Access control for backup and restore operations

"""
This feature verifies that backup and restore operations can only be initiated by identities explicitly authorized for backup/restore functions. It also verifies that unauthorized attempts fail with an access denied message.
"""

@CCC.RDMS.CN04.AR01.TE01
Scenario: Unauthorized identity is denied when initiating a backup
   Given an identity whose credentials or roles are not explicitly authorized for backup/restore functions
   When the identity attempts to initiate a backup of the database
   Then the attempt should fail with an access denied message

@CCC.RDMS.CN04.AR01.TE02
Scenario: Unauthorized identity is denied when initiating a restore
   Given an identity whose credentials or roles are not explicitly authorized for backup/restore functions
   When the identity attempts to initiate a restore of the database
   Then the attempt should fail with an access denied message

@CCC.RDMS.CN04.AR01.TE03
Scenario: Authorized backup role is allowed to initiate a backup
   Given an identity with a role explicitly authorized for backup/restore functions
   When the identity attempts to initiate a backup of the database
   Then the backup operation should be permitted
