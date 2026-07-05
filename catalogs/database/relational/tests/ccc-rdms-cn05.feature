@CCC.RDMS.CN05.AR01
Feature: Restrict snapshot sharing to authorized accounts

"""
This feature verifies that database snapshots can only be shared with explicitly authorized accounts, minimizing the risk of data exposure or exfiltration through snapshot sharing.
"""

@CCC.RDMS.CN05.AR01.TE01
Scenario: Sharing a snapshot with an unauthorized account is denied
   Given a snapshot of the database exists
   When an attempt is made to share the snapshot with an account that is not explicitly authorized
   Then the sharing request should be denied

@CCC.RDMS.CN05.AR01.TE02
Scenario: Sharing a snapshot with an authorized account succeeds
   Given a snapshot of the database exists
   When an attempt is made to share the snapshot with an explicitly authorized account
   Then the sharing request should succeed
