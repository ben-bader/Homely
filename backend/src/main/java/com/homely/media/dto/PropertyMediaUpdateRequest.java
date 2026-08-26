package com.homely.media.dto;

import com.homely.common.enums.MediaType;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PropertyMediaUpdateRequest {
    private MediaType mediaType;
    private String url;
    private String thumbnailUrl;
    private int displayOrder;
    private int durationSeconds;
}
