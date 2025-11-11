@echo off
echo Starting Robot Framework Remote Keywords Server...
java -DREMOTE_HOST=127.0.0.1 -DREMOTE_PORT=8270 -jar keywords-remote\target\keywords-remote-1.0.0.jar

