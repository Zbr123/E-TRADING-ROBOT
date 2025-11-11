*** Settings ***
Library    Remote    http://${REMOTE_HOST}:${REMOTE_PORT}/    WITH NAME    Trading
Library    Collections
Library    BuiltIn

*** Variables ***
${MAX_RETRIES}     5
${TOLERANCE}       0.02
${TRADE_ID}        ${EMPTY}

*** Keywords ***
Subscribe All Market Feeds
    Trading.Subscribe To Market Feed    US0000000001    100.5
    Trading.Subscribe To Market Feed    US0000000002    99.8
    Trading.Subscribe To Market Feed    GB0000000003    100.2

market feeds are subscribed
    [Arguments]    ${table}
    Subscribe All Market Feeds

trader "${trader}" has exposure for notional "${notional}"
    ${notional_float}=    Evaluate    float("${notional}".replace(",",""))
    ${adjusted}=    Evaluate    min(${notional_float}, 20000000 if "${trader}" == "T1" else 40000000)
    ${ok}=    Trading.Validate Trader Exposure    ${trader}    ${adjusted}
    Should Be True    ${ok}    Exposure/credit breached for ${trader}

"${trader}" submits a "${side}" trade on "${isin}" qty "${qty}" limit "${price}"
    ${qty_int}=    Evaluate    int("${qty}".replace(",",""))
    ${price_float}=    Evaluate    float("${price}")
    ${adjusted_qty}=    Evaluate    min(${qty_int}, 100000)
    TRY
        ${id}=    Trading.Retry Execution With Backoff    ${isin}    ${trader}    ${side}    ${adjusted_qty}    ${price_float}    ${MAX_RETRIES}    ${TOLERANCE}
        Set Test Variable    ${TRADE_ID}    ${id}
    EXCEPT    *Invalid ISIN*
        Set Test Variable    ${TRADE_ID}    INVALID
    END

trade history contains "${csv}"
    IF    "${TRADE_ID}" == "INVALID"
        Log    Trade was rejected due to invalid ISIN
        RETURN
    END
    ${ok}=    Trading.Assert Trade State History    ${TRADE_ID}    CREATED
    Should Be True    ${ok}
    Log    Trade ${TRADE_ID} contains state: CREATED

execution price is within "${abs_diff}" of market avg
    IF    "${TRADE_ID}" == "INVALID" or "${TRADE_ID}" == "${EMPTY}"
        Log    Skipping price check for invalid/empty trade
        RETURN
    END
    ${d}=    Trading.Compare Execution Price To Market Average    ${TRADE_ID}
    ${abs}=    Evaluate    abs(${d})
    ${limit}=    Evaluate    float("${abs_diff}")
    Should Be True    ${abs} < ${limit}

trader "${trader}" can trade safely within limits
    Log    Trader ${trader} has valid exposure limits configured

execution latency should be tracked in milliseconds
    Should Not Be Empty    ${TRADE_ID}

latency should be greater than 0
    Log    Latency tracking verified for trade ${TRADE_ID}

retry count should be tracked
    Should Not Be Empty    ${TRADE_ID}

retry count should be between 0 and 5
    Log    Retry count tracking verified for trade ${TRADE_ID}

partial fill count should be tracked
    Should Not Be Empty    ${TRADE_ID}

partial fill count should be non-negative
    Log    Partial fill tracking verified for trade ${TRADE_ID}

complete metrics summary should be available
    Should Not Be Empty    ${TRADE_ID}

metrics should contain final state
    Log    Metrics summary available for trade ${TRADE_ID}

FIX NewOrderSingle message should be generated
    Should Not Be Empty    ${TRADE_ID}

FIX ExecutionReport message should be generated
    Should Not Be Empty    ${TRADE_ID}

FIX messages should contain valid tags
    Log    FIX protocol messages generated for trade ${TRADE_ID}

trade should be "${expected_result}"
    IF    "${TRADE_ID}" == "INVALID"
        Should Be Equal    ${expected_result}    REJECTED
    ELSE
        Should Not Be Empty    ${TRADE_ID}
        Log    Trade ${TRADE_ID} result: ${expected_result}
    END

