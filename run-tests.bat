@echo off
echo Activating Python virtual environment...
call .venv\Scripts\activate.bat

echo Setting environment variables...
set REMOTE_HOST=127.0.0.1
set REMOTE_PORT=8270

echo Running Robot Framework tests with Gherkin syntax...
robot --listener allure_robotframework;outdir=tests-robot/logs/allure-results --consolecolors on --variable REMOTE_HOST:%REMOTE_HOST% --variable REMOTE_PORT:%REMOTE_PORT% -d tests-robot/logs --language Gherkin:en tests-robot/features

echo.
echo Tests completed! Check reports at:
echo   - tests-robot/logs/report.html
echo   - tests-robot/logs/log.html
pause

