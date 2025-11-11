# E-Trading BDD Test Automation

A comprehensive BDD (Behavior-Driven Development) test automation framework for electronic trading systems, built with:
- **Java 17** - Core business logic and mock trading services
- **Maven 3.9+** - Build and dependency management
- **Robot Framework 7.3+** - BDD test automation with Gherkin support
- **Python 3.11+** - Test execution runtime
- **Allure** - Enhanced test reporting

## Project Structure

```
E-Trading-robot/
├── services-core/              # Java core services (domain models + business logic)
│   ├── src/main/java/
│   │   └── com/example/trading/
│   │       ├── enums/         # Side, TradeState
│   │       ├── model/         # Instrument, Trader, Trade
│   │       ├── service/       # InstrumentService, MarketDataService, CreditService, TradeService
│   │       └── util/          # Backoff utility
│   └── pom.xml
├── keywords-remote/            # Robot Framework remote library server
│   ├── src/main/java/
│   │   └── com/example/keywords/
│   │       ├── TradingKeywords.java    # Robot keyword implementations
│   │       └── ServerMain.java         # Remote server entry point
│   └── pom.xml
├── tests-robot/                # Robot Framework BDD tests
│   ├── features/              # Gherkin .feature files
│   │   └── bond_trading.feature
│   ├── resources/             # Robot resource files
│   │   └── trading_bdd.resource
│   └── logs/                  # Test execution logs & reports
├── .github/workflows/         # CI/CD pipeline
│   └── ci.yml
├── pom.xml                    # Parent Maven POM
├── start-server.bat           # Start remote keywords server
├── run-tests.bat              # Run Robot Framework tests
└── README.md
```

## Features Tested

The framework tests a complete e-trading lifecycle including:

1. **Valid Trade Execution** - Create and confirm trades
2. **Invalid ISIN Handling** - Reject trades with invalid instruments
3. **Price Deviation Control** - Enforce market tolerance limits
4. **Idempotency** - Handle duplicate execution attempts
5. **Retry with Backoff** - Recover from transient failures
6. **Partial Fills** - Handle incomplete order execution
7. **Pre-confirmation Cancellation** - Cancel orders before confirmation
8. **Concurrent Trading** - Multiple traders operating simultaneously
9. **Rapid Market Updates** - Handle real-time price changes
10. **Risk Breach Prevention** - Enforce exposure limits

## Prerequisites

- **Java 17** or higher
- **Maven 3.9+**
- **Python 3.10+** (with pip)
- **(Optional)** Allure CLI for enhanced reporting

## Quick Start

### 1. Build the Project

```bash
mvn clean install -DskipTests
```

This creates:
- `services-core/target/services-core-1.0.0.jar` - Core trading services
- `keywords-remote/target/keywords-remote-1.0.0.jar` - Shaded JAR with all dependencies

### 2. Set Up Python Environment

```bash
# Create virtual environment
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate

# Activate (Linux/Mac)
source .venv/bin/activate

# Install dependencies
pip install robotframework allure-robotframework
```

### 3. Start the Remote Keywords Server

**Option A: Using batch script (Windows)**
```bash
start-server.bat
```

**Option B: Manual command**
```bash
java -DREMOTE_HOST=127.0.0.1 -DREMOTE_PORT=8270 -jar keywords-remote/target/keywords-remote-1.0.0.jar
```

Keep this terminal open. The server will log:
```
Remote Server starting at 127.0.0.1:8270
```

### 4. Run the Tests

**Option A: Using batch script (Windows)**
```bash
run-tests.bat
```

**Option B: Manual command**
```bash
# Set environment variables (Windows)
set REMOTE_HOST=127.0.0.1
set REMOTE_PORT=8270

# Set environment variables (Linux/Mac)
export REMOTE_HOST=127.0.0.1
export REMOTE_PORT=8270

# Run tests
robot --listener allure_robotframework;outdir=tests-robot/logs/allure-results \
  --consolecolors on \
  --variable REMOTE_HOST:${REMOTE_HOST} \
  --variable REMOTE_PORT:${REMOTE_PORT} \
  -d tests-robot/logs \
  --language Gherkin:en \
  tests-robot/features
```

### 5. View Reports

**Robot Framework Reports:**
- Open `tests-robot/logs/report.html` in a browser for summary
- Open `tests-robot/logs/log.html` for detailed execution log

**Allure Report (if CLI installed):**
```bash
allure generate tests-robot/logs/allure-results -o tests-robot/logs/allure-report --clean
allure open tests-robot/logs/allure-report
```

## Architecture

### Java Services Layer

- **Instrument Service**: Manages bond instruments (ISIN lookup, yield curves)
- **Market Data Service**: Real-time price feeds with tick simulation
- **Credit Service**: Enforces trader exposure limits
- **Trade Service**: Order lifecycle management with retry logic

### Robot Framework Integration

- **Remote Library Protocol**: Java keywords exposed via XML-RPC
- **Gherkin Syntax**: Natural language BDD scenarios
- **Keyword Mapping**: Robot resource files bind Gherkin steps to Java methods

### Test Scenarios

All scenarios in `tests-robot/features/bond_trading.feature` follow Given-When-Then format:

```gherkin
Scenario: Create and confirm valid trade
  Given trader "T1" has exposure for notional "101000000.0"
  When "T1" submits a "BUY" trade on "US0000000001" qty "1000000" limit "101.0"
  Then trade history contains "CREATED,EXECUTED,PENDING_CONFIRMATION,CONFIRMED"
  And execution price is within "0.5" of market avg
```

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`) automatically:
1. Builds Maven project
2. Starts remote server in background
3. Runs all Robot Framework tests
4. Uploads test artifacts (reports + Allure results)

Triggered on every `push` and `pull_request`.

## Customization

### Add New Keywords

1. Add method to `keywords-remote/src/main/java/com/example/keywords/TradingKeywords.java`:
```java
@RobotKeyword
public void myNewKeyword(String param) {
    // Implementation
}
```

2. Rebuild: `mvn clean install -DskipTests`
3. Use in Robot resource file with camelCase converted to spaces: `My New Keyword`

### Add New Test Scenarios

Edit `tests-robot/features/bond_trading.feature` and add Gherkin scenarios using existing keywords from `tests-robot/resources/trading_bdd.resource`.

## Troubleshooting

**Server won't start:**
- Check Java version: `java -version` (must be 17+)
- Check port 8270 isn't in use: `netstat -an | findstr 8270`
- Check JAR exists: `keywords-remote/target/keywords-remote-1.0.0.jar`

**Tests fail to connect:**
- Ensure server is running before tests
- Verify `REMOTE_HOST=127.0.0.1` and `REMOTE_PORT=8270`
- Check firewall isn't blocking port 8270

**Import errors:**
- Activate virtual environment: `.venv\Scripts\activate`
- Reinstall packages: `pip install robotframework allure-robotframework`

## License

MIT License - feel free to adapt for your trading system needs.

