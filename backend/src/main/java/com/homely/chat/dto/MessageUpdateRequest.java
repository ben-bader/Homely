package com.homely.chat.dto;

import java.time.Instant;
import java.util.Map;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MessageUpdateRequest {
    private String body;
    private Map<String, Object> attachments;
    private Instant readAt;
}
