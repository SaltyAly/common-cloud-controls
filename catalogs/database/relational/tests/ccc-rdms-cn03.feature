@CCC.RDMS.CN03.AR01
Feature: Alerting and logging when automated backups are disabled or fail

"""
This feature verifies that disabling automated backups, or the failure of a scheduled backup, triggers an alert and produces a log entry so that disruptions to backup coverage are promptly reported.
"""

@CCC.RDMS.CN03.AR01.TE01
Scenario: Disabling automated backups raises an alert and a log entry
   Given a database instance with automated backups enabled and backup monitoring configured
   When automated backups are disabled on the instance
   Then an alert should be triggered for the backup configuration change
   And a log entry should record that automated backups were disabled
   And automated backups should be re-enabled on the instance afterwards

@CCC.RDMS.CN03.AR01.TE02
Scenario: A failed scheduled backup raises an alert and a log entry
   Given a database instance with automated backups enabled and backup monitoring configured
   When a scheduled backup fails to run as expected
   Then an alert should be triggered for the failed backup
   And a log entry should record the backup failure
