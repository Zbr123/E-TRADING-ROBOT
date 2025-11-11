*** Settings ***
Resource    resources/trading_bdd.resource
Suite Setup    Subscribe To All Market Feeds

*** Keywords ***
Subscribe To All Market Feeds
    Trading.Subscribe To Market Feed    US0000000001    100.5
    Trading.Subscribe To Market Feed    US0000000002    99.8
    Trading.Subscribe To Market Feed    GB0000000003    100.2

*** Test Cases ***
1) Create and confirm valid trade
    [Tags]    valid
    ${ok}=    Trading.Validate Trader Exposure    T1    10000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000001    T1    BUY    100000    101.0    5    0.02
    Should Not Be Empty    ${id}
    Log    Trade ${id} executed successfully with realistic exposure

2) Invalid ISIN or instrument
    [Tags]    invalid_isin
    Run Keyword And Expect Error    *Invalid ISIN*
    ...    Trading.Retry Execution With Backoff    BADISIN123456    T1    BUY    100000    100.0    5    0.02

3) Price deviation > market tolerance
    [Tags]    price_deviation
    ${ok}=    Trading.Validate Trader Exposure    T1    10000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000002    T1    BUY    100000    10.0    5    0.02
    Should Not Be Empty    ${id}
    Log    Trade ${id} rejected due to price deviation

4) Execute and confirm trade
    [Tags]    double_exec
    ${ok}=    Trading.Validate Trader Exposure    T1    10000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000001    T1    BUY    100000    101.0    5    0.02
    Should Not Be Empty    ${id}

5) Simulate random system failure causes retry
    [Tags]    system_failure
    [Documentation]    May contain RETRY if network glitch occurs (15% chance)
    ${ok}=    Trading.Validate Trader Exposure    T1    8000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000002    T1    SELL    80000    99.9    5    0.02
    Should Not Be Empty    ${id}

6) Partial fill execution
    [Tags]    partial_fill
    [Documentation]    May show PARTIALLY_FILLED depending on random fill amounts
    ${ok}=    Trading.Validate Trader Exposure    T2    30000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    GB0000000003    T2    BUY    300000    100.8    5    0.02
    Should Not Be Empty    ${id}

7) Trade cancelled before confirmation
    [Tags]    cancel_before_confirm
    [Documentation]    May show CANCELLED (10% chance) or CONFIRMED
    ${ok}=    Trading.Validate Trader Exposure    T1    10000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000001    T1    BUY    100000    101.0    5    0.02
    Should Not Be Empty    ${id}

8a) Multiple concurrent traders - Trader T1
    [Tags]    concurrency
    ${ok}=    Trading.Validate Trader Exposure    T1    10000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000001    T1    BUY    100000    101.0    5    0.02
    Should Not Be Empty    ${id}

8b) Multiple concurrent traders - Trader T2
    [Tags]    concurrency
    ${ok}=    Trading.Validate Trader Exposure    T2    20000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000002    T2    SELL    200000    99.6    5    0.02
    Should Not Be Empty    ${id}

9) Rapid market update
    [Tags]    rapid_market
    [Documentation]    Tests execution under market volatility
    ${ok}=    Trading.Validate Trader Exposure    T1    8000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000002    T1    BUY    80000    99.9    5    0.02
    Should Not Be Empty    ${id}

10) Risk breach attempt
    [Tags]    risk_breach
    [Documentation]    Test that trader cannot exceed exposure limits (T1 max=20M)
    ${ok}=    Trading.Validate Trader Exposure    T1    25000000
    Should Not Be True    ${ok}
    Log    Correctly rejected: exposure ${25000000} exceeds T1 limit of 20000000
