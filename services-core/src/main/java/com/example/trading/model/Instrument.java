package com.example.trading.model;

public record Instrument(String isin, String currency, double tenorYrs, double yieldPct) {}

