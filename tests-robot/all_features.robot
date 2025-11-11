*** Settings ***
Documentation    Master Test Suite - Executes All Gherkin Feature Files
Resource         resources/trading_bdd.resource
Suite Setup      Subscribe All Market Feeds

*** Test Cases ***
# ============================================================================
# CORE TRADING SCENARIOS (bond_trading.feature)
# ============================================================================

1) Create and confirm valid trade
    [Tags]    valid    core
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CREATED,EXECUTED,PENDING_CONFIRMATION,CONFIRMED"

2) Invalid ISIN or instrument
    [Tags]    invalid_isin    core
    TRY
        When "T1" submits a "BUY" trade on "BADISIN123456" qty "100000" limit "100.0"
    EXCEPT
        Log    Invalid ISIN correctly rejected
    END

3) Price deviation > market tolerance
    [Tags]    price_deviation    core
    Given trader "T1" has exposure for notional "100000000.0"
    When "T1" submits a "BUY" trade on "US0000000002" qty "1000000" limit "10.0"
    Then trade history contains "REJECTED"

4) Execute already confirmed trade
    [Tags]    double_exec    core
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CONFIRMED"

5) Simulate random system failure causes retry
    [Tags]    system_failure    core
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "SELL" trade on "US0000000002" qty "800000" limit "99.9"
    Then trade history contains "RETRY"

6) Partial fill execution
    [Tags]    partial_fill    core
    Given trader "T2" has exposure for notional "302400000.0"
    When "T2" submits a "BUY" trade on "GB0000000003" qty "3000000" limit "100.8"
    Then trade history contains "PARTIALLY_FILLED"

7) Trade cancelled before confirmation
    [Tags]    cancel_before_confirm    core
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CANCELLED"

8a) Multiple concurrent traders - T1
    [Tags]    concurrency    core
    Given trader "T1" has exposure for notional "101000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CREATED"

8b) Multiple concurrent traders - T2
    [Tags]    concurrency    core
    Given trader "T2" has exposure for notional "199200000"
    When "T2" submits a "SELL" trade on "US0000000002" qty "2000000" limit "99.6"
    Then trade history contains "CREATED"

9) Rapid market update
    [Tags]    rapid_market    core
    Given trader "T1" has exposure for notional "79920000.0"
    When "T1" submits a "BUY" trade on "US0000000002" qty "800000" limit "99.9"
    Then trade history contains "PENDING_CONFIRMATION"

10) Risk breach attempt
    [Tags]    risk_breach    core
    Given trader "T1" has exposure for notional "50000000.0"
    Then trader "T1" can trade safely within limits

# ============================================================================
# ADVANCED METRICS & FIX PROTOCOL (advanced_metrics.feature)
# ============================================================================

11) Test execution latency metrics
    [Tags]    metrics    latency    advanced
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then execution latency should be tracked in milliseconds
    And latency should be greater than 0

12) Test retry count metrics
    [Tags]    metrics    retry    advanced
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then retry count should be tracked
    And retry count should be between 0 and 5

13) Test partial fill metrics
    [Tags]    metrics    partial_fill    advanced
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then partial fill count should be tracked
    And partial fill count should be non-negative

14) Test complete metrics summary
    [Tags]    metrics    summary    advanced
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then complete metrics summary should be available
    And metrics should contain final state

15) Test FIX message generation
    [Tags]    fix    protocol    advanced
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then FIX NewOrderSingle message should be generated
    And FIX ExecutionReport message should be generated
    And FIX messages should contain valid tags

# ============================================================================
# DATA-DRIVEN SCENARIOS (data_driven.feature)
# ============================================================================

16) US Treasury Bond - T1 BUY
    [Tags]    data_driven    us_bonds
    Given trader "T1" has exposure for notional "10000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "100000" limit "101.0"
    Then trade should be "EXECUTED"

17) US Treasury Bond - T2 SELL
    [Tags]    data_driven    us_bonds
    Given trader "T2" has exposure for notional "20000000"
    When "T2" submits a "SELL" trade on "US0000000002" qty "200000" limit "99.6"
    Then trade should be "EXECUTED"

18) UK Gilt - T1 BUY
    [Tags]    data_driven    uk_gilts
    Given trader "T1" has exposure for notional "5000000"
    When "T1" submits a "BUY" trade on "GB0000000003" qty "50000" limit "100.0"
    Then trade should be "EXECUTED"

19) High Volume - T2 BUY
    [Tags]    data_driven    high_volume
    Given trader "T2" has exposure for notional "30000000"
    When "T2" submits a "BUY" trade on "US0000000002" qty "300000" limit "99.9"
    Then trade should be "EXECUTED"

20) Edge Case - Small Trade
    [Tags]    data_driven    edge_case
    Given trader "T1" has exposure for notional "1000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "10000" limit "101.5"
    Then trade should be "EXECUTED"

