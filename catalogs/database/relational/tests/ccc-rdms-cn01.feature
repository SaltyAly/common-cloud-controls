@CCC.RDMS.CN01.AR02
Feature: Default vendor-supplied database credentials must not grant access

"""
This feature verifies that default vendor-supplied administrator credentials cannot be used to authenticate to the database. It also verifies that properly managed replacement credentials continue to grant access.
"""

@CCC.RDMS.CN01.AR02.TE01
Scenario: Confirm that access attempts using default credentials are denied
   Given the database management system was provisioned with vendor-supplied default credentials
   When an authentication attempt is made using the known default credentials
   Then the authentication attempt should fail
   And no access should be granted to the database

@CCC.RDMS.CN01.AR02.TE02
Scenario: Confirm that rotated credentials managed in a secrets management solution grant access
   Given the default administrator credentials have been replaced with a strong, unique password stored in a secrets management solution
   When an authentication attempt is made using the current credentials retrieved from the secrets management solution
   Then the authentication attempt should succeed
