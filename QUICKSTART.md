# Quick Start Guide

## Step-by-Step Execution

### Terminal 1: Start the Keywords Server

```bash
# Option 1: Use the batch script
start-server.bat

# Option 2: Manual command
java -DREMOTE_HOST=127.0.0.1 -DREMOTE_PORT=8270 -jar keywords-remote\target\keywords-remote-1.0.0.jar
```

**Wait for this message:**
```
Remote Server starting at 127.0.0.1:8270
```

**Keep this terminal open!**

---

### Terminal 2: Run the Tests

```bash
# Run the batch script
run-tests.bat

# OR manually:
.venv\Scripts\activate
set REMOTE_HOST=127.0.0.1
set REMOTE_PORT=8270
robot --listener allure_robotframework;outdir=tests-robot/logs/allure-results ^
      --consolecolors on ^
      --variable REMOTE_HOST:%REMOTE_HOST% ^
      --variable REMOTE_PORT:%REMOTE_PORT% ^
      -d tests-robot/logs ^
      --language Gherkin:en ^
      tests-robot/features
```

---

### View Results

1. **Open in browser:** `tests-robot\logs\report.html`
2. **Detailed log:** `tests-robot\logs\log.html`
3. **Allure (optional):**
   ```bash
   allure generate tests-robot/logs/allure-results -o tests-robot/logs/allure-report --clean
   allure open tests-robot/logs/allure-report
   ```

---

## Expected Output

You should see 10 test scenarios executed:

```
==============================================================================
Bond Trading :: Advanced E-Trading lifecycle (mock)
==============================================================================
1) Create and confirm valid trade                                     | PASS |
2) Invalid ISIN or instrument                                         | PASS |
3) Price deviation > market tolerance                                 | PASS |
4) Execute already confirmed trade (second attempt fails)             | PASS |
5) Simulate random system failure causes retry                        | PASS |
6) Partial fill execution                                             | PASS |
7) Trade cancelled before confirmation                                | PASS |
8) Multiple concurrent traders (simulate via two scenarios)
  - Example row 1                                                     | PASS |
  - Example row 2                                                     | PASS |
9) Rapid market update (pending confirmation should appear)           | PASS |
10) Risk breach attempt (exposure denied)                             | PASS |
==============================================================================
```

---

## Test Scenarios Explained

| Scenario | What It Tests |
|----------|---------------|
| **1. Valid Trade** | Normal trade lifecycle: CREATED → EXECUTED → PENDING_CONFIRMATION → CONFIRMED |
| **2. Invalid ISIN** | Rejects trades with unknown instruments |
| **3. Price Deviation** | Rejects when execution price deviates too far from limit |
| **4. Idempotency** | Confirms trade only once (no double execution) |
| **5. Retry Logic** | Recovers from simulated network failures using exponential backoff |
| **6. Partial Fill** | Handles incomplete order fills |
| **7. Cancellation** | Cancels trade before final confirmation |
| **8. Concurrency** | Multiple traders can operate simultaneously |
| **9. Market Updates** | Handles rapid price changes |
| **10. Risk Limits** | Enforces trader exposure limits |

---

## Troubleshooting

### Server fails to start
```bash
# Check Java version
java -version

# Check if port is already in use
netstat -an | findstr 8270

# Rebuild if JAR is missing
mvn clean install -DskipTests
```

### Tests can't connect to server
```bash
# Verify server is running (see Terminal 1)
# Check environment variables
echo %REMOTE_HOST%
echo %REMOTE_PORT%
```

### Python package errors
```bash
# Ensure venv is activated (you should see (.venv) in prompt)
.venv\Scripts\activate

# Reinstall packages
pip install --force-reinstall robotframework allure-robotframework
```

---

## Next Steps

1. **Modify Tests**: Edit `tests-robot/features/bond_trading.feature`
2. **Add Keywords**: Update `keywords-remote/src/main/java/com/example/keywords/TradingKeywords.java`
3. **Extend Services**: Add new business logic in `services-core/src/main/java/com/example/trading/`
4. **Rebuild**: After Java changes, run `mvn clean install -DskipTests` and restart server

---

## Directory Reference

| Path | Contents |
|------|----------|
| `services-core/` | Java domain models and business services |
| `keywords-remote/` | Robot Framework keyword bridge |
| `tests-robot/features/` | Gherkin BDD scenarios |
| `tests-robot/resources/` | Robot keyword definitions |
| `tests-robot/logs/` | Test execution reports |
| `.venv/` | Python virtual environment |
| `pom.xml` | Maven parent project |

Enjoy testing! 🚀

