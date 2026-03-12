package com.homely.boost.dto;

import java.math.BigDecimal;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
@Getter
@Setter
@RequiredArgsConstructor
public class BoostPackageDto {
    private Long id;
    private String name;
    private String description;
    private int durationDays;
    private BigDecimal price;

    // Getters and setters
}