@CCC.Core.CN09
Feature: Protect audit logs and logging configuration from tampering

"""
This feature verifies the integrity of access logs by ensuring that logging cannot be disabled from within the service context, even by users with administrative roles.
"""

@CCC.Core.CN09.TE01
Scenario: Confirm that administrative users cannot disable logging
   Given a user with the role "DatabaseAdmin"
   When the user tries to disable logging
   Then the user should be denied the ability to disable logging
