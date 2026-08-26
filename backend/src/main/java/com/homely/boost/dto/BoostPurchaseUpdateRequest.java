package com.homely.boost.dto;

import com.homely.common.enums.PurchaseStatus;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BoostPurchaseUpdateRequest {
    private PurchaseStatus status;
    private String paymentProviderRef;
}
