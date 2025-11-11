package com.example.keywords;

import org.robotframework.javalib.annotation.RobotKeyword;
import com.example.trading.enums.Side;
import com.example.trading.model.Trade;
import com.example.trading.service.*;
import java.util.*;

public class TradingKeywords {
  public final InstrumentService instrumentService = new InstrumentService();
  public final MarketDataService marketDataService = new MarketDataService();
  public final CreditService creditService = new CreditService();
  public final TradeService tradeService = new TradeService(marketDataService, creditService);

  @RobotKeyword
  public void subscribeToMarketFeed(String isin, double startMid){ marketDataService.startTicksFor(isin, startMid); }

  @RobotKeyword
  public boolean validateTraderExposure(String traderId, double notional){ return tradeService.validateExposure(traderId, notional); }

  @RobotKeyword
  public String retryExecutionWithBackoff(String isin, String traderId, String side, long qty, double limitPx, int maxRetries, double toleranceFraction){
    if (instrumentService.findByIsin(isin).isEmpty()) throw new RuntimeException("Invalid ISIN");
    String id = UUID.randomUUID().toString();
    tradeService.create(id, isin, traderId, Side.valueOf(side), qty, limitPx);
    tradeService.executeWithRetry(id, maxRetries, toleranceFraction);
    return id;
  }

  @RobotKeyword
  public boolean assertTradeStateHistory(String tradeId, String csvStates){
    List<String> exp = List.of(csvStates.split("\\s*,\\s*"));
    return tradeService.history(tradeId).stream().map(Enum::name).toList().containsAll(exp);
  }

  @RobotKeyword
  public double compareExecutionPriceToMarketAverage(String tradeId){
    Trade t = tradeService.get(tradeId);
    return tradeService.avgVsMarket(t.isin, t.execPx);
  }
  
  @RobotKeyword
  public String generateFIXNewOrder(String tradeId) {
    Trade t = tradeService.get(tradeId);
    if (t == null) return "Trade not found";
    com.example.trading.model.FIXMessage msg = com.example.trading.model.FIXMessage.newOrderSingle(
      t.id, t.isin, t.side.name(), t.qty, t.limitPx
    );
    return msg.toFIXString();
  }
  
  @RobotKeyword
  public String generateFIXExecutionReport(String tradeId) {
    Trade t = tradeService.get(tradeId);
    if (t == null) return "Trade not found";
    String execType = switch(t.state) {
      case CREATED -> "0"; // New
      case EXECUTED -> "F"; // Trade (partial fill or filled)
      case PARTIALLY_FILLED -> "1"; // Partial fill
      case CONFIRMED -> "F"; // Trade
      case REJECTED -> "8"; // Rejected
      case CANCELLED -> "4"; // Canceled
      default -> "0";
    };
    String ordStatus = switch(t.state) {
      case CREATED -> "0"; // New
      case PARTIALLY_FILLED -> "1"; // Partially filled
      case EXECUTED, CONFIRMED -> "2"; // Filled
      case CANCELLED -> "4"; // Canceled
      case REJECTED -> "8"; // Rejected
      default -> "A"; // Pending
    };
    com.example.trading.model.FIXMessage msg = com.example.trading.model.FIXMessage.executionReport(
      t.id, "EXEC-" + t.id.substring(0, 8), execType, ordStatus,
      t.isin, t.side.name(), t.filledQty, t.execPx
    );
    return msg.toFIXString();
  }
}

