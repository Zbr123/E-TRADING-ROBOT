package com.example.trading.service;

import com.example.trading.model.Instrument;
import java.util.*; import java.util.concurrent.ThreadLocalRandom;

public class InstrumentService {
  private final Map<String, Instrument> db = new HashMap<>();
  public InstrumentService(){
    db.put("US0000000001", new Instrument("US0000000001","USD",5, rand()));
    db.put("US0000000002", new Instrument("US0000000002","USD",10, rand()));
    db.put("GB0000000003", new Instrument("GB0000000003","GBP",7, rand()));
  }
  private double rand(){ return ThreadLocalRandom.current().nextDouble(2.0, 8.0); }
  public Optional<Instrument> findByIsin(String isin){ return Optional.ofNullable(db.get(isin)); }
}

