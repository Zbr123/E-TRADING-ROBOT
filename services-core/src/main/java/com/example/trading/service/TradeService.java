package com.example.trading.service;

import com.example.trading.enums.*; import com.example.trading.model.*; import com.example.trading.util.Backoff;
import java.util.*; import java.util.concurrent.ConcurrentHashMap;

public class TradeService {
  private final MarketDataService mkt; private final CreditService credit;
  private final Map<String, Trader> traders = new ConcurrentHashMap<>(); private final Map<String, Trade> trades = new ConcurrentHashMap<>();
  public TradeService(MarketDataService mkt,CreditService credit){ this.mkt=mkt; this.credit=credit;
    traders.put("T1", new Trader("T1", 5_000_000, 20_000_000));
    traders.put("T2", new Trader("T2",10_000_000, 40_000_000));
  }
  public Trader getTrader(String id){ return Objects.requireNonNull(traders.get(id), "Unknown trader"); }
  public Trade create(String id,String isin,String traderId,Side side,long qty,double limitPx){
    Trade t = new Trade(id, isin, traderId, side, qty, limitPx); trades.put(t.id, t); return t; }
  public void executeWithRetry(String tradeId,int maxRetries,double toleranceFraction){
    Trade t = trades.get(tradeId);
    for (int attempt=0; attempt<=maxRetries; attempt++){
      try {
        if (Math.random() < 0.15) throw new RuntimeException("Network glitch");
        double mid = mkt.mid(t.isin); double px = mid + (t.side==Side.BUY? +0.1 : -0.1);
        if (Math.abs(px - t.limitPx)/t.limitPx > toleranceFraction){ t.pushState(TradeState.REJECTED); return; }
        long chunk = (long)Math.max(1, t.qty*(0.25 + Math.random()*0.5));
        t.execPx = px; t.filledQty += Math.min(chunk, t.qty - t.filledQty);
        t.pushState(t.filledQty < t.qty ? TradeState.PARTIALLY_FILLED : TradeState.EXECUTED);
        if (t.filledQty < t.qty) continue;
        t.pushState(TradeState.PENDING_CONFIRMATION);
        if (Math.random() < 0.10){ t.pushState(TradeState.CANCELLED); return; }
        t.pushState(TradeState.CONFIRMED); return;
      } catch(Exception e){
        t.pushState(TradeState.RETRY);
        if (attempt==maxRetries){ t.pushState(TradeState.REJECTED); return; }
        Backoff.sleepExp(attempt);
      }
    }
  }
  public boolean validatePerTradeLimit(String traderId,double notional){ return getTrader(traderId).maxLimit() >= notional; }
  public boolean validateExposure(String traderId,double notional){ return credit.canOpen(getTrader(traderId), notional); }
  public List<TradeState> history(String id){ return trades.get(id).history; }
  public double avgVsMarket(String isin,double execPx){ return execPx - mkt.marketAvg(isin); }
  public Trade get(String id){ return trades.get(id); }
}

