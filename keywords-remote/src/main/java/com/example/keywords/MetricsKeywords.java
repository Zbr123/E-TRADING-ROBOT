package com.example.keywords;

import org.robotframework.javalib.annotation.RobotKeyword;
import com.example.trading.model.Trade;
import com.example.trading.model.TradeMetrics;
import com.example.trading.service.*;

public class MetricsKeywords {
    private final TradingKeywords tradingKeywords;
    
    public MetricsKeywords(TradingKeywords tradingKeywords) {
        this.tradingKeywords = tradingKeywords;
    }
    
    @RobotKeyword
    public long getTradeExecutionLatency(String tradeId) {
        Trade trade = tradingKeywords.tradeService.get(tradeId);
        if (trade == null) return -1;
        return trade.metrics.executionLatencyMs;
    }
    
    @RobotKeyword
    public int getTradeRetryCount(String tradeId) {
        Trade trade = tradingKeywords.tradeService.get(tradeId);
        if (trade == null) return -1;
        return trade.metrics.retryCount;
    }
    
    @RobotKeyword
    public int getTradePartialFillCount(String tradeId) {
        Trade trade = tradingKeywords.tradeService.get(tradeId);
        if (trade == null) return -1;
        return trade.metrics.partialFillCount;
    }
    
    @RobotKeyword
    public String getTradeMetricsSummary(String tradeId) {
        Trade trade = tradingKeywords.tradeService.get(tradeId);
        if (trade == null) return "Trade not found";
        return trade.metrics.toString();
    }
}

