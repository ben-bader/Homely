package com.homely.analytics.dto;

import java.util.List;
import java.util.Map;

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
public class MediaStatsResponse {
    private long totalMediaFiles;
    private long totalImages;
    private long totalVideos;
    private double averageMediaPerProperty;
    private Map<String, Long> mediaByType;
    private Map<String, Long> mediaUploadedOverTime;
    private List<MediaPropertyCountDto> topPropertiesByMediaCount;
    private long propertiesWithNoMedia;
}
