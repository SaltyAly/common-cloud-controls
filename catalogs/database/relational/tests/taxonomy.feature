# Common Cloud Controls RDMS Taxonomy Feature
@CCC-RDMS-Taxonomy
Feature: Relational Database Management System Taxonomy
    As a decision-maker or regulator for a financial services organization
    I want to ensure that an RDMS system contains the minimum capabilities required for the service to be portable with other RDMS systems
    So that I can ensure that the system is not locked into a single vendor

    Background:
        Given a RDMS system is reachable from a known endpoint
        And credentials have been supplied with sufficient permissions to create a new table and user

    @CCC-RDMS-1
    Scenario: Ensure the system supports properly handles queries in the SQL language
        Given the seeded fixture "employees.sql" has been loaded into the database
        When the following query is executed: "<QUERY>"
        Then the system returns an expected value: "<RESPONSE>"

    Examples:
        | QUERY                                                                                                                     | RESPONSE                  |
        | SELECT COUNT(*) FROM employees                                                                                            | 10                        |
        | SELECT name FROM employees WHERE id = 1                                                                                   | Ada Lovelace              |
        | SELECT employees.name, departments.name FROM employees INNER JOIN departments ON employees.department_id = departments.id WHERE employees.id = 2 | Grace Hopper, Engineering |
        | SELECT MAX(salary) FROM employees                                                                                         | 120000                    |
        | SELECT COUNT(*) FROM employees WHERE department_id = 1                                                                    | 4                         |

    @CCC-RDMS-2
    Scenario: Ensure the system supports vertical scaling
        When the system is scaled vertically to "<SIZE>" of the original value
        Then the reported instance size matches the requested size

    Examples:
        | SIZE |
        | 2x   |
        | 8x   |
        | 4x   |

    @CCC-RDMS-3
    Scenario: Ensure the system supports horizontal scaling via read replicas
        When a read replica is created in the same region as the primary database
        And data is inserted into the primary database
        Then the data can be found in the read replica
    
    @CCC-RDMS-4
    Scenario: Ensure the system supports horizontal scaling via read replicas in multiple regions
        When a read replica exists in a different region from the primary database
        And data is inserted into the primary database
        Then the data can be found in the read replica

    @CCC-RDMS-5
    Scenario: Ensure the system supports automated backups
        When automated backups are enabled
        Then the system creates a backup at the specified interval
        And the backup can be found in the expected location

    @CCC-RDMS-6
    Scenario: Ensure the system supports point in time recovery
        When a backup is restored to a specific point in time
        Then the restored database contains the data state as it existed at that point in time
        And changes made after that point in time are not present in the restored database

    @CCC-RDMS-7
    Scenario: Ensure the system supports encryption at rest
        When encryption at rest is enabled
        Then the storage configuration reports encryption enabled for the instance
    
    @CCC-RDMS-8
    Scenario: Ensure the system supports encryption in transit
        When encryption in transit is enabled
        Then a connection attempt made without TLS is refused
    
    @CCC-RDMS-9
    Scenario: Ensure the system supports role based access control
        When a new user is created with the following permissions: "<PERMISSIONS>"
        Then the user can perform the following actions: "<ALLOWED>"
        And the user cannot perform the following actions: "<DENIED>"

    Examples:
        | PERMISSIONS | ALLOWED | DENIED |
        | SELECT         | SELECT  | INSERT, UPDATE, DELETE |
        | SELECT, INSERT | SELECT, INSERT | UPDATE, DELETE |
        | SELECT, INSERT, UPDATE | SELECT, INSERT, UPDATE | DELETE |
        | SELECT, INSERT, UPDATE, DELETE | SELECT, INSERT, UPDATE, DELETE | |

    @CCC-RDMS-10
    Scenario: Ensure the system supports logging
        When logging is enabled
        And a known test statement is executed against the database
        Then the executed statement appears in the database log

    @CCC-RDMS-11
    Scenario: Ensure the system supports monitoring
        When monitoring is enabled
        Then the metrics endpoint returns datapoints for the instance
    
    @CCC-RDMS-12
    Scenario: Ensure the system supports alerting
        When alerting is enabled
        And a configured alert's threshold condition is met
        Then the configured alert fires
    
    @CCC-RDMS-13
    Scenario: Ensure the system can support failover
        When the system has a standby database configured
        And the primary database has become unreachable
        Then the system should use the standby system instead
