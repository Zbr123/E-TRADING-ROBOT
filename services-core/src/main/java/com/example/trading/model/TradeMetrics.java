package com.example.trading.model;

import java.time.Duration;
import java.time.Instant;

public class TradeMetrics {
    public final String tradeId;
    public final Instant startTime;
    public Instant endTime;
    public int retryCount = 0;
    public long executionLatencyMs = 0;
    public int partialFillCount = 0;
    public String finalState;
    
    public TradeMetrics(String tradeId) {
        this.tradeId = tradeId;
        this.startTime = Instant.now();
    }
    
    public void complete(String state) {
        this.endTime = Instant.now();
        this.finalState = state;
        this.executionLatencyMs = Duration.between(startTime, endTime).toMillis();
    }
    
    public void incrementRetry() {
        this.retryCount++;
    }
    
    public void incrementPartialFill() {
        this.partialFillCount++;
    }
    
    @Override
    public String toString() {
        return String.format("TradeMetrics[id=%s, latency=%dms, retries=%d, partialFills=%d, state=%s]",
            tradeId, executionLatencyMs, retryCount, partialFillCount, finalState);
    }
}

