package com.homely.analytics.dto;

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
public class MediaPropertyCountDto {
    private UUID propertyId;
    private String propertyTitle;
    private long mediaCount;
}
