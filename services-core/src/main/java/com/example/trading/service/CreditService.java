package com.example.trading.service;

import com.example.trading.model.Trader;

public class CreditService {
  public boolean canOpen(Trader t, double notional){ return t.exposure() + notional <= t.maxExposure(); }
}

