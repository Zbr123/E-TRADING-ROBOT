package com.example.trading.model;

import java.util.concurrent.atomic.AtomicReference;

public class Trader {
  private final String id; private final double maxLimit; private final double maxExposure;
  private final AtomicReference<Double> exposure = new AtomicReference<>(0.0);
  public Trader(String id,double maxLimit,double maxExposure){this.id=id;this.maxLimit=maxLimit;this.maxExposure=maxExposure;}
  public String id(){return id;} public double maxLimit(){return maxLimit;} public double maxExposure(){return maxExposure;}
  public double addExposure(double d){return exposure.updateAndGet(v->v+d);} public double exposure(){return exposure.get();}
}

