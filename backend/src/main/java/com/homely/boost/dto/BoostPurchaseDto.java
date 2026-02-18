package com.homely.boost.dto;

import java.math.BigDecimal;
import java.util.UUID;

import com.homely.common.enums.PurchaseStatus;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoostPurchaseDto {

    private UUID id;

    private UUID sellerId;
    private UUID propertyId;

    private String propertyTitle;
    private String userName;
    private String userEmail;

    private BigDecimal amount;
    private String currency;
    private int durationDays;

    private PurchaseStatus status;
}
