package com.homely.chat.dto;

import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ConversationDto {
    private UUID id;
    private UUID propertyId;
    private UUID clientId;
    private UUID sellerId;
}
