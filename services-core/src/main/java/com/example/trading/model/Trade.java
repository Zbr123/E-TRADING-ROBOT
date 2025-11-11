package com.example.trading.model;

import com.example.trading.enums.Side; import com.example.trading.enums.TradeState;
import java.time.Instant; import java.util.ArrayList; import java.util.List;

public class Trade {
  public final String id, isin, traderId; public final Side side; public final long qty; public final double limitPx;
  public volatile double execPx=0.0; public volatile long filledQty=0; public volatile TradeState state=TradeState.CREATED;
  public final List<TradeState> history=new ArrayList<>(); public final Instant createdAt=Instant.now();
  public final TradeMetrics metrics;
  
  public Trade(String id,String isin,String traderId,Side side,long qty,double limitPx){
    this.id=id; this.isin=isin; this.traderId=traderId; this.side=side; this.qty=qty; this.limitPx=limitPx; 
    history.add(TradeState.CREATED);
    this.metrics = new TradeMetrics(id);
  }
  public synchronized void pushState(TradeState s){ 
    state=s; 
    history.add(s);
    if (s == TradeState.RETRY) metrics.incrementRetry();
    if (s == TradeState.PARTIALLY_FILLED) metrics.incrementPartialFill();
    if (s == TradeState.CONFIRMED || s == TradeState.REJECTED || s == TradeState.CANCELLED) {
      metrics.complete(s.name());
    }
  }
}

