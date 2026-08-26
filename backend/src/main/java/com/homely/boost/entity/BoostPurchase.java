package com.homely.boost.entity;

import java.math.BigDecimal;
import java.time.Instant;

import com.homely.common.base.BaseEntity;
import com.homely.common.enums.PurchaseStatus;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class BoostPurchase extends BaseEntity {

    @ManyToOne
    private User seller;

    @ManyToOne
    private Property property;

    private BigDecimal amount;
    private String currency;
    private int durationDays;

    @Enumerated(EnumType.STRING)
    private PurchaseStatus status;

    private String paymentProviderRef;
    
    // ✅ Boost expiry timestamp
    private Instant expiryAt;
}
