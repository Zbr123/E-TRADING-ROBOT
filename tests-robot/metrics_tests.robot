*** Settings ***
Resource    resources/trading_bdd.resource
Library    Remote    http://${REMOTE_HOST}:${REMOTE_PORT}/metrics    WITH NAME    Metrics
Suite Setup    Subscribe To All Market Feeds

*** Keywords ***
Subscribe To All Market Feeds
    Trading.Subscribe To Market Feed    US0000000001    100.5
    Trading.Subscribe To Market Feed    US0000000002    99.8
    Trading.Subscribe To Market Feed    GB0000000003    100.2

*** Test Cases ***
Test Execution Latency Metrics
    [Documentation]    Verify execution latency is tracked and reasonable
    [Tags]    metrics    performance
    ${ok}=    Trading.Validate Trader Exposure    T1    10000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000001    T1    BUY    100000    101.0    5    0.02
    Should Not Be Empty    ${id}
    
    ${latency}=    Metrics.Get Trade Execution Latency    ${id}
    ${latency_num}=    Convert To Number    ${latency}
    Should Be True    ${latency_num} >= 0
    Should Be True    ${latency_num} < 10000    # Should complete in under 10 seconds
    Log    ⏱️ Execution latency: ${latency}ms

Test Retry Count Metrics
    [Documentation]    Verify retry attempts are counted (15% failure rate)
    [Tags]    metrics    resilience
    ${ok}=    Trading.Validate Trader Exposure    T1    8000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000002    T1    SELL    80000    99.9    5    0.02
    Should Not Be Empty    ${id}
    
    ${retry_count}=    Metrics.Get Trade Retry Count    ${id}
    Should Be True    ${retry_count} >= 0
    Should Be True    ${retry_count} <= 5
    Log    🔄 Retry count: ${retry_count}

Test Partial Fill Metrics
    [Documentation]    Verify partial fill count is tracked
    [Tags]    metrics    execution
    ${ok}=    Trading.Validate Trader Exposure    T2    30000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    GB0000000003    T2    BUY    300000    100.8    5    0.02
    Should Not Be Empty    ${id}
    
    ${partial_fills}=    Metrics.Get Trade Partial Fill Count    ${id}
    Should Be True    ${partial_fills} >= 0
    Log    ⚠️ Partial fill count: ${partial_fills}

Test Complete Metrics Summary
    [Documentation]    Get complete metrics summary for a trade
    [Tags]    metrics    reporting
    ${ok}=    Trading.Validate Trader Exposure    T1    10000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000001    T1    BUY    100000    101.0    5    0.02
    Should Not Be Empty    ${id}
    
    ${summary}=    Metrics.Get Trade Metrics Summary    ${id}
    Should Contain    ${summary}    TradeMetrics
    Should Contain    ${summary}    latency
    Should Contain    ${summary}    retries
    Should Contain    ${summary}    partialFills
    Log    📊 Metrics Summary: ${summary}

Test FIX Message Generation
    [Documentation]    Verify FIX protocol messages are generated correctly
    [Tags]    fix    protocol
    ${ok}=    Trading.Validate Trader Exposure    T1    10000000
    Should Be True    ${ok}
    ${id}=    Trading.Retry Execution With Backoff    US0000000001    T1    BUY    100000    101.0    5    0.02
    Should Not Be Empty    ${id}
    
    ${fix_order}=    Trading.Generate FIX New Order    ${id}
    Should Contain    ${fix_order}    35=D    # Message Type = New Order Single
    Should Contain    ${fix_order}    55=US0000000001    # Symbol
    Should Contain    ${fix_order}    54=1    # Side = Buy
    Should Contain    ${fix_order}    38=100000    # Order Quantity
    Log    📝 FIX New Order: ${fix_order}
    
    ${fix_exec}=    Trading.Generate FIX Execution Report    ${id}
    Should Contain    ${fix_exec}    35=8    # Message Type = Execution Report
    Should Contain    ${fix_exec}    55=US0000000001    # Symbol
    Log    📝 FIX Execution Report: ${fix_exec}

Test Multiple Trades Performance Metrics
    [Documentation]    Track average metrics across multiple trades
    [Tags]    metrics    performance    bulk
    @{trade_ids}=    Create List
    @{latencies}=    Create List
    
    FOR    ${i}    IN RANGE    5
        ${ok}=    Trading.Validate Trader Exposure    T2    5000000
        Should Be True    ${ok}
        ${id}=    Trading.Retry Execution With Backoff    US0000000002    T2    BUY    50000    99.9    5    0.02
        Should Not Be Empty    ${id}
        Append To List    ${trade_ids}    ${id}
        ${latency}=    Metrics.Get Trade Execution Latency    ${id}
        ${latency_num}=    Convert To Number    ${latency}
        Append To List    ${latencies}    ${latency_num}
        Log    Trade ${i+1}: ${id} - Latency: ${latency}ms
    END
    
    ${total_latency}=    Evaluate    sum(${latencies})
    ${avg_latency}=    Evaluate    ${total_latency} / len(${latencies})
    Log    📈 Average execution latency across 5 trades: ${avg_latency}ms
    Should Be True    ${avg_latency} < 5000    # Average should be under 5 seconds

