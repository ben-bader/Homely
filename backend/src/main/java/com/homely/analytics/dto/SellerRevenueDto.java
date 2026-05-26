package com.homely.analytics.dto;

import java.math.BigDecimal;
import java.util.UUID;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellerRevenueDto {
    private UUID sellerId;
    private String sellerName;
    private String sellerEmail;
    private BigDecimal revenue;
}
