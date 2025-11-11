Feature: Advanced Trading Metrics and FIX Protocol

  Background:
    Given market feeds are subscribed:
      | ISIN           | MidPrice |
      | US0000000001   | 100.5    |
      | US0000000002   | 99.8     |
      | GB0000000003   | 100.2    |

  @metrics @latency
  Scenario: Test execution latency metrics
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then execution latency should be tracked in milliseconds
    And latency should be greater than 0

  @metrics @retry
  Scenario: Test retry count metrics
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then retry count should be tracked
    And retry count should be between 0 and 5

  @metrics @partial_fill
  Scenario: Test partial fill metrics
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then partial fill count should be tracked
    And partial fill count should be non-negative

  @metrics @summary
  Scenario: Test complete metrics summary
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then complete metrics summary should be available
    And metrics should contain final state

  @fix @protocol
  Scenario: Test FIX message generation
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then FIX NewOrderSingle message should be generated
    And FIX ExecutionReport message should be generated
    And FIX messages should contain valid tags

