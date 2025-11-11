package com.example.keywords;

import org.robotframework.remoteserver.RemoteServer;

public class ServerMain {
  public static void main(String[] args) throws Exception {
    RemoteServer.configureLogging();
    RemoteServer server = new RemoteServer();
    TradingKeywords trading = new TradingKeywords();
    MetricsKeywords metrics = new MetricsKeywords(trading);
    server.putLibrary("/", trading);
    server.putLibrary("/metrics", metrics);
    server.setHost(System.getProperty("REMOTE_HOST","0.0.0.0"));
    server.setPort(Integer.parseInt(System.getProperty("REMOTE_PORT","8270")));
    server.start();
  }
}

