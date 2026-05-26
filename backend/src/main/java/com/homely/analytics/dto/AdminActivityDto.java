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
public class AdminActivityDto {
    private UUID adminId;
    private String adminName;
    private String adminEmail;
    private long actionCount;
}
