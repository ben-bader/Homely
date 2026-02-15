package com.homely.notification.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NotificationCreateRequest {

    @NotNull
    private UUID userId;
    @NotNull
    private String type;
    private String payload;
}
