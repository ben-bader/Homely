package com.homely.chat.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ConversationCreateRequest {
    private UUID propertyId;
    private UUID clientId;
    private UUID sellerId;
}
