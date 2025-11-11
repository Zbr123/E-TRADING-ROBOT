*** Settings ***
Resource    resources/trading_bdd.resource
Suite Setup    Subscribe All Market Feeds

*** Test Cases ***
1) Create and confirm valid trade
    [Tags]    valid
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CREATED,EXECUTED,PENDING_CONFIRMATION,CONFIRMED"
    And execution price is within "100.0" of market avg

2) Invalid ISIN or instrument
    [Tags]    invalid_isin
    TRY
        When "T1" submits a "BUY" trade on "BADISIN123456" qty "100000" limit "100.0"
    EXCEPT
        Log    Invalid ISIN correctly rejected
    END

3) Price deviation > market tolerance
    [Tags]    price_deviation
    Given trader "T1" has exposure for notional "100000000.0"
    When "T1" submits a "BUY" trade on "US0000000002" qty "1000000" limit "10.0"
    Then trade history contains "REJECTED"

4) Execute already confirmed trade
    [Tags]    double_exec
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CONFIRMED"

5) Simulate random system failure causes retry
    [Tags]    system_failure
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "SELL" trade on "US0000000002" qty "800000" limit "99.9"
    Then trade history contains "RETRY"

6) Partial fill execution
    [Tags]    partial_fill
    Given trader "T2" has exposure for notional "302400000.0"
    When "T2" submits a "BUY" trade on "GB0000000003" qty "3000000" limit "100.8"
    Then trade history contains "PARTIALLY_FILLED"

7) Trade cancelled before confirmation
    [Tags]    cancel_before_confirm
    Given trader "T1" has exposure for notional "101000000.0"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CANCELLED"

8a) Multiple concurrent traders - T1
    [Tags]    concurrency
    Given trader "T1" has exposure for notional "101000000"
    When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
    Then trade history contains "CREATED"

8b) Multiple concurrent traders - T2
    [Tags]    concurrency
    Given trader "T2" has exposure for notional "199200000"
    When "T2" submits a "SELL" trade on "US0000000002" qty "2000000" limit "99.6"
    Then trade history contains "CREATED"

9) Rapid market update
    [Tags]    rapid_market
    Given trader "T1" has exposure for notional "79920000.0"
    When "T1" submits a "BUY" trade on "US0000000002" qty "800000" limit "99.9"
    Then trade history contains "PENDING_CONFIRMATION"

10) Risk breach attempt
    [Tags]    risk_breach
    Given trader "T1" has exposure for notional "50000000.0"

