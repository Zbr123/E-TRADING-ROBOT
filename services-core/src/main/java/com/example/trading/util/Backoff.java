package com.example.trading.util;

public class Backoff {
  public static void sleepExp(int attempt){
    long ms = (long)Math.min(2000, 100 * Math.pow(2, attempt));
    try { Thread.sleep(ms); } catch (InterruptedException ignored) {}
  }
}

