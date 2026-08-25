@CCC.RDMS.CN02.AR01
Feature: Account lockout and rate-limiting after repeated failed login attempts

"""
This feature verifies that the database enforces an account lockout or rate-limiting policy when repeated failed authentication attempts are made in a short timeframe, preventing brute force and password-guessing attacks from succeeding.
"""

@CCC.RDMS.CN02.AR01.TE01
Scenario: Repeated failed logins in a short window trigger lockout or throttling
   Given a database account subject to a lockout or rate-limiting policy
   When repeated failed login attempts are made against the account within a short timeframe
   Then the account should be locked out or further login attempts should be rate-limited
   And subsequent login attempts during the lockout or throttling period should be rejected
