package com.example.trading.service;

import java.util.concurrent.*;

public class MarketDataService {
  private final ConcurrentMap<String, Double> midPx = new ConcurrentHashMap<>();
  private final ScheduledExecutorService ses = Executors.newScheduledThreadPool(2);
  public void startTicksFor(String isin, double start){
    midPx.putIfAbsent(isin, start);
    ses.scheduleAtFixedRate(() -> midPx.computeIfPresent(isin,(k,v)-> v + ThreadLocalRandom.current().nextDouble(-0.5,0.5)),
      0, 300, TimeUnit.MILLISECONDS);
  }
  public double mid(String isin){ return midPx.getOrDefault(isin, 100.0); }
  public double marketAvg(String isin){ return mid(isin); }
}

