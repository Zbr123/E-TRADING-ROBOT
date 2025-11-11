*** Settings ***
Resource    resources/trading_bdd.resource
Library     OperatingSystem
Library     String
Suite Setup    Setup Market Data From CSV

*** Keywords ***
Setup Market Data From CSV
    ${csv_content}=    Get File    tests-robot/test-data/market_data.csv
    @{lines}=    Split To Lines    ${csv_content}
    Remove From List    ${lines}    0    # Remove header
    FOR    ${line}    IN    @{lines}
        # Skip empty lines
        ${line_stripped}=    Strip String    ${line}
        Continue For Loop If    '${line_stripped}' == ''
        @{fields}=    Split String    ${line}    ,
        ${isin}=    Set Variable    ${fields}[0]
        ${mid}=    Set Variable    ${fields}[3]
        Trading.Subscribe To Market Feed    ${isin}    ${mid}
    END

Parse CSV Trade Row
    [Arguments]    ${row}
    @{fields}=    Split String    ${row}    ,
    ${trader}=    Set Variable    ${fields}[0]
    ${isin}=    Set Variable    ${fields}[1]
    ${side}=    Set Variable    ${fields}[2]
    ${qty}=    Set Variable    ${fields}[3]
    ${limit}=    Set Variable    ${fields}[4]
    ${expected}=    Set Variable    ${fields}[5]
    ${desc}=    Set Variable    ${fields}[6]
    RETURN    ${trader}    ${isin}    ${side}    ${qty}    ${limit}    ${expected}    ${desc}

Execute Trade From CSV
    [Arguments]    ${trader}    ${isin}    ${side}    ${qty}    ${limit}    ${expected}
    ${notional}=    Evaluate    ${qty} * ${limit}
    ${exposure_ok}=    Trading.Validate Trader Exposure    ${trader}    ${notional}
    
    IF    '${expected}' == 'INVALID_ISIN'
        Run Keyword And Expect Error    *Invalid ISIN*
        ...    Trading.Retry Execution With Backoff    ${isin}    ${trader}    ${side}    ${qty}    ${limit}    5    0.02
    ELSE IF    '${expected}' == 'SUCCESS' and ${exposure_ok}
        ${id}=    Trading.Retry Execution With Backoff    ${isin}    ${trader}    ${side}    ${qty}    ${limit}    5    0.02
        Should Not Be Empty    ${id}
        RETURN    ${id}
    ELSE IF    '${expected}' == 'PRICE_DEVIATION'
        ${id}=    Trading.Retry Execution With Backoff    ${isin}    ${trader}    ${side}    ${qty}    ${limit}    5    0.02
        Should Not Be Empty    ${id}
        RETURN    ${id}
    ELSE
        ${id}=    Trading.Retry Execution With Backoff    ${isin}    ${trader}    ${side}    ${qty}    ${limit}    5    0.02
        Should Not Be Empty    ${id}
        RETURN    ${id}
    END

*** Test Cases ***
Data Driven Tests From CSV
    [Documentation]    Execute all trades defined in CSV file
    [Tags]    data_driven    csv
    ${csv_content}=    Get File    tests-robot/test-data/trades.csv
    @{lines}=    Split To Lines    ${csv_content}
    Remove From List    ${lines}    0    # Remove header
    
    ${test_count}=    Set Variable    ${0}
    FOR    ${line}    IN    @{lines}
        # Skip empty lines
        ${line_stripped}=    Strip String    ${line}
        Continue For Loop If    '${line_stripped}' == ''
        ${test_count}=    Evaluate    ${test_count} + 1
        ${trader}    ${isin}    ${side}    ${qty}    ${limit}    ${expected}    ${desc}=
        ...    Parse CSV Trade Row    ${line}
        Log    Test ${test_count}: ${desc}
        TRY
            ${trade_id}=    Execute Trade From CSV    ${trader}    ${isin}    ${side}    ${qty}    ${limit}    ${expected}
            Log    ✅ Trade executed: ${trade_id} - ${desc}
        EXCEPT    AS    ${error}
            IF    '${expected}' == 'INVALID_ISIN'
                Log    ✅ Expected error for invalid ISIN: ${desc}
            ELSE
                Fail    Unexpected error: ${error}
            END
        END
    END
    Log    Completed ${test_count} data-driven test cases from CSV

