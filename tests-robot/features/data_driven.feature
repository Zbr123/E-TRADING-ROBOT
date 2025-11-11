Feature: Data-Driven Trading Tests

  Background:
    Given market feeds are subscribed:
      | ISIN           | MidPrice |
      | US0000000001   | 100.5    |
      | US0000000002   | 99.8     |
      | GB0000000003   | 100.2    |

  @data_driven @csv
  Scenario Outline: Execute trades from test data
    Given trader "<Trader>" has exposure for notional "<Notional>"
    When "<Trader>" submits a "<Side>" trade on "<ISIN>" qty "<Qty>" limit "<Limit>"
    Then trade should be "<ExpectedResult>"

    Examples: US Treasury Bonds
      | Trader | Notional  | Side | ISIN           | Qty    | Limit | ExpectedResult |
      | T1     | 10000000  | BUY  | US0000000001   | 100000 | 101.0 | EXECUTED       |
      | T2     | 20000000  | SELL | US0000000002   | 200000 | 99.6  | EXECUTED       |
      | T1     | 5000000   | BUY  | US0000000001   | 50000  | 100.8 | EXECUTED       |

    Examples: UK Gilts
      | Trader | Notional  | Side | ISIN           | Qty    | Limit | ExpectedResult |
      | T1     | 5000000   | BUY  | GB0000000003   | 50000  | 100.0 | EXECUTED       |
      | T2     | 15000000  | SELL | GB0000000003   | 150000 | 100.5 | EXECUTED       |

    Examples: High Volume
      | Trader | Notional  | Side | ISIN           | Qty    | Limit | ExpectedResult |
      | T2     | 30000000  | BUY  | US0000000002   | 300000 | 99.9  | EXECUTED       |
      | T2     | 25000000  | SELL | US0000000001   | 250000 | 100.3 | EXECUTED       |

    Examples: Edge Cases
      | Trader | Notional  | Side | ISIN           | Qty    | Limit  | ExpectedResult |
      | T1     | 1000000   | BUY  | US0000000001   | 10000  | 101.5  | EXECUTED       |

