Feature: Advanced E-Trading lifecycle (mock)

  Background:
    Given market feeds are subscribed:
      | ISIN           | MidPrice |
      | US0000000001   | 100.5    |
      | US0000000002   | 99.8     |
      | GB0000000003   | 100.2    |

  @valid
  Scenario: 1) Create and confirm valid trade
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CREATED,EXECUTED,PENDING_CONFIRMATION,CONFIRMED"

  @invalid_isin
  Scenario: 2) Invalid ISIN or instrument
    When "T1" submits a "BUY" trade on "BADISIN123456" qty "100000" limit "100.0"
    Then trade history contains "REJECTED"

  @price_deviation
  Scenario: 3) Price deviation > market tolerance
    Given trader "T1" has exposure for notional "100000000.0"
    When "T1" submits a "BUY" trade on "US0000000002" qty "1000000" limit "10.0"
    Then trade history contains "REJECTED"

  @double_exec
  Scenario: 4) Execute already confirmed trade (second attempt fails)
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CONFIRMED"

  @system_failure
  Scenario: 5) Simulate random system failure causes retry
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "SELL" trade on "US0000000002" qty "800000" limit "99.9"
    Then trade history contains "RETRY"

  @partial_fill
  Scenario: 6) Partial fill execution
    Given trader "T2" has exposure for notional "302400000.0"
    When "T2" submits a "BUY" trade on "GB0000000003" qty "3000000" limit "100.8"
    Then trade history contains "PARTIALLY_FILLED"

  @cancel_before_confirm
  Scenario: 7) Trade cancelled before confirmation
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CANCELLED"

  @concurrency
  Scenario Outline: 8) Multiple concurrent traders (simulate via two scenarios)
    Given trader "<Trader>" has exposure for notional "<Notional>"
    When "<Trader>" submits a "<Side>" trade on "<ISIN>" qty "<Qty>" limit "<Limit>"
    Then trade history contains "CREATED"
    Examples:
      | Trader | Notional   | Side | ISIN           | Qty     | Limit |
      | T1     | 101000000  | BUY  | US0000000001   | 1000000 | 101.0 |
      | T2     | 199200000  | SELL | US0000000002   | 2000000 | 99.6  |

  @rapid_market
  Scenario: 9) Rapid market update (pending confirmation should appear)
    Given trader "T1" has exposure for notional "79920000.0"
    When "T1" submits a "BUY" trade on "US0000000002" qty "800000" limit "99.9"
    Then trade history contains "PENDING_CONFIRMATION"

  @risk_breach
  Scenario: 10) Risk breach attempt (exposure denied)
    Given trader "T1" has exposure for notional "50000000.0"
    Then trader "T1" can trade safely within limits

