@CCC.Core @CCC.Core.CN01 @tlp-amber @tlp-clear @tlp-green @tlp-red @tls
Feature: CCC.Core.CN01.AR02
  As a security administrator
  I want to ensure all SSH network traffic uses SSHv2 or higher
  So that SSH connections are properly encrypted and secure


@Behavioural @PerPort @ssh @virtual-machines
  Scenario: Verify SSH protocol version
    SSH protocol version 2 (SSH-2.0) is required as SSH-1 has known security vulnerabilities
    including man-in-the-middle attacks and session hijacking. This test ensures that the
    server advertises SSH-2.0 in its protocol banner and successfully establishes a connection.

    Given a client connects to "{host-name}" with protocol "ssh" on port "{port-number}"
    And I refer to "{result}" as "connection"
    And "{connection}" is not an error
    # Fixed wait for the server's protocol banner to arrive; the DSL has no wait-until/poll step.
    And we wait for a period of "500" ms
    And I attach "{connection.Output}" to the test output as "SSH banner"
    And "{connection.Output}" contains "SSH-2.0"
    And I close connection "{connection}"
    Then "{connection}" state is closed


@Behavioural @PerPort @ssh @virtual-machines @NotTestable
  Scenario: SSH cipher and algorithm strength cannot be audited automatically
    # SSH does not negotiate TLS cipher suites or present X.509 server certificates, so
    # TLS-scanner checks cannot verify anything about an SSH endpoint. Automated SSH
    # algorithm auditing needs an ssh-audit-style DSL step that does not exist yet.
    #
    # Manual verification steps:
    # 1. Run ssh-audit (or ssh -Q cipher) against "{host-name}" on port "{port-number}"
    # 2. Confirm no weak algorithms are offered: 3des-cbc, arcfour, hmac-md5,
    #    diffie-hellman-group1-sha1
    Then no-op required
