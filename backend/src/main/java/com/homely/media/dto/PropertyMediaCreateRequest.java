package com.homely.media.dto;

import java.util.UUID;

import com.homely.common.enums.MediaType;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PropertyMediaCreateRequest {

    @NotNull
    private UUID propertyId;
    @NotNull
    private MediaType mediaType;
    private String url;
    private String thumbnailUrl;
    private int displayOrder;
    private int durationSeconds;
}
