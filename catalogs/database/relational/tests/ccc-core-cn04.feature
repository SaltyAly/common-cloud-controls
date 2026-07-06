@CCC.Core.CN04
Feature: Log all access and changes to the database

"""
This feature verifies that administrative actions, data writes, and data reads against the database each produce entries in the corresponding audit log category, maintaining a detailed audit trail for security and compliance purposes.
"""

@CCC.Core.CN04.TE01
Scenario: Administrative actions produce audit log entries
   # For example, a configuration change qualifies as an administrative action.
   Given a database instance with audit logging enabled for administrative activity
   When an administrative action is performed on the database
   Then the administrative activity audit log should contain an entry for the action
   And the entry should record the client identity
   And the entry should record the time of the action
   And the entry should record the result of the action

@CCC.Core.CN04.TE02
Scenario: Data writes produce audit log entries
   # For example, an INSERT or UPDATE statement qualifies as a data write.
   Given a database instance with audit logging enabled for data modification activity
   When a data write is executed against a table
   Then the data modification audit log should contain an entry for the write
   And the entry should record the client identity
   And the entry should record the time of the write
   And the entry should record the result of the write

@CCC.Core.CN04.TE03
Scenario: Data reads produce audit log entries
   Given a database instance with audit logging enabled for data read activity
   When a SELECT statement is executed against a table
   Then the data read audit log should contain an entry for the read
   And the entry should record the client identity
   And the entry should record the time of the read
   And the entry should record the result of the read
