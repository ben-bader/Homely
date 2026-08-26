package com.homely.media.dto;

import java.time.Instant;
import java.util.UUID;
import com.homely.common.enums.MediaType;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PropertyMediaDto {
    private UUID id;
    private UUID propertyId;
    private MediaType mediaType;
    private String url;
    private String thumbnailUrl;
    private int displayOrder;
    private int durationSeconds;

    private Instant createdAt;
    private Instant updatedAt;
}
