package com.homely.notification.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NotificationCreateRequest {
    private String type;
    private String payload;
}
