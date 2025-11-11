package com.example.trading.model;

import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

/**
 * Simplified FIX Protocol 4.4 message representation
 * Real FIX would use QuickFIX/J library
 */
public class FIXMessage {
    private final Map<Integer, String> fields = new HashMap<>();
    private final String msgType;
    
    // FIX Message Types
    public static final String NEW_ORDER_SINGLE = "D";
    public static final String EXECUTION_REPORT = "8";
    public static final String ORDER_CANCEL_REQUEST = "F";
    
    // Common FIX Tags
    public static final int MSG_TYPE = 35;
    public static final int SENDER_COMP_ID = 49;
    public static final int TARGET_COMP_ID = 56;
    public static final int MSG_SEQ_NUM = 34;
    public static final int SENDING_TIME = 52;
    public static final int CL_ORD_ID = 11;
    public static final int SYMBOL = 55;
    public static final int SIDE = 54;
    public static final int ORDER_QTY = 38;
    public static final int ORD_TYPE = 40;
    public static final int PRICE = 44;
    public static final int EXEC_TYPE = 150;
    public static final int ORD_STATUS = 39;
    public static final int EXEC_ID = 17;
    public static final int LAST_QTY = 32;
    public static final int LAST_PX = 31;
    public static final int CUM_QTY = 14;
    public static final int AVG_PX = 6;
    
    public FIXMessage(String msgType) {
        this.msgType = msgType;
        fields.put(MSG_TYPE, msgType);
        fields.put(SENDING_TIME, DateTimeFormatter.ISO_INSTANT.format(Instant.now()));
    }
    
    public FIXMessage setField(int tag, String value) {
        fields.put(tag, value);
        return this;
    }
    
    public FIXMessage setField(int tag, int value) {
        return setField(tag, String.valueOf(value));
    }
    
    public FIXMessage setField(int tag, double value) {
        return setField(tag, String.format("%.2f", value));
    }
    
    public String getField(int tag) {
        return fields.get(tag);
    }
    
    public String toFIXString() {
        StringBuilder sb = new StringBuilder();
        fields.entrySet().stream()
            .sorted(Map.Entry.comparingByKey())
            .forEach(e -> sb.append(e.getKey()).append("=").append(e.getValue()).append("|"));
        return sb.toString();
    }
    
    @Override
    public String toString() {
        return String.format("FIX[%s]: %s", msgType, toFIXString());
    }
    
    // Factory methods for common messages
    public static FIXMessage newOrderSingle(String clOrdId, String symbol, String side, long qty, double price) {
        return new FIXMessage(NEW_ORDER_SINGLE)
            .setField(SENDER_COMP_ID, "CLIENT")
            .setField(TARGET_COMP_ID, "EXCHANGE")
            .setField(CL_ORD_ID, clOrdId)
            .setField(SYMBOL, symbol)
            .setField(SIDE, side.equals("BUY") ? "1" : "2")
            .setField(ORDER_QTY, qty)
            .setField(ORD_TYPE, "2") // Limit order
            .setField(PRICE, price);
    }
    
    public static FIXMessage executionReport(String clOrdId, String execId, String execType, String ordStatus,
                                            String symbol, String side, long cumQty, double avgPx) {
        return new FIXMessage(EXECUTION_REPORT)
            .setField(SENDER_COMP_ID, "EXCHANGE")
            .setField(TARGET_COMP_ID, "CLIENT")
            .setField(CL_ORD_ID, clOrdId)
            .setField(EXEC_ID, execId)
            .setField(EXEC_TYPE, execType)
            .setField(ORD_STATUS, ordStatus)
            .setField(SYMBOL, symbol)
            .setField(SIDE, side.equals("BUY") ? "1" : "2")
            .setField(CUM_QTY, cumQty)
            .setField(AVG_PX, avgPx);
    }
}

