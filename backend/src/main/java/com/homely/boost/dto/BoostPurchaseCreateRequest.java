package com.homely.boost.dto;

import java.math.BigDecimal;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoostPurchaseCreateRequest {
    private UUID propertyId;
    private BigDecimal amount;
    private String currency;
    private int durationDays;
    private String paymentProviderRef;
}
