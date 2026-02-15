package com.homely.boost.dto;

import java.math.BigDecimal;
import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoostPurchaseCreateRequest {

    @NotNull
    private UUID propertyId;
    @NotNull
    private BigDecimal amount;
    private String currency;
    private int durationDays;
    private String paymentProviderRef;
}
