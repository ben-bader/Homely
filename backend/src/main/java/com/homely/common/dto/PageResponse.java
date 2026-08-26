package com.homely.common.dto;

import java.util.List;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Generic paginated response wrapper
 * Wraps list content with pagination metadata
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PageResponse<T> {
    
    @JsonProperty("content")
    private List<T> content;
    
    @JsonProperty("pageNumber")
    private int pageNumber;
    
    @JsonProperty("pageSize")
    private int pageSize;
    
    @JsonProperty("totalElements")
    private long totalElements;
    
    @JsonProperty("totalPages")
    private int totalPages;
    
    @JsonProperty("isFirst")
    private boolean isFirst;
    
    @JsonProperty("isLast")
    private boolean isLast;
    
    @JsonProperty("hasNext")
    private boolean hasNext;
    
    @JsonProperty("hasPrevious")
    private boolean hasPrevious;
}
