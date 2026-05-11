package com.homely.common.util;

import java.util.List;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;

import com.homely.common.dto.PageResponse;

/**
 * Utility for converting Spring Data Page to PageResponse DTO
 */
public class PaginationUtil {

    private PaginationUtil() {
        // Utility class, no instantiation
    }

    /**
     * Convert Spring Page to PageResponse
     */
    public static <T> PageResponse<T> toPageResponse(Page<T> page) {
        return PageResponse.<T>builder()
                .content(page.getContent())
                .pageNumber(page.getNumber())
                .pageSize(page.getSize())
                .totalElements(page.getTotalElements())
                .totalPages(page.getTotalPages())
                .isFirst(page.isFirst())
                .isLast(page.isLast())
                .hasNext(page.hasNext())
                .hasPrevious(page.hasPrevious())
                .build();
    }

    /**
     * Convert Spring Page to PageResponse with mapping function
     */
    public static <S, T> PageResponse<T> toPageResponse(Page<S> page, Function<S, T> mapper) {
        List<T> mappedContent = page.getContent()
                .stream()
                .map(mapper)
                .collect(Collectors.toList());

        return PageResponse.<T>builder()
                .content(mappedContent)
                .pageNumber(page.getNumber())
                .pageSize(page.getSize())
                .totalElements(page.getTotalElements())
                .totalPages(page.getTotalPages())
                .isFirst(page.isFirst())
                .isLast(page.isLast())
                .hasNext(page.hasNext())
                .hasPrevious(page.hasPrevious())
                .build();
    }

    /**
     * Default page number (0-indexed, starting from first page)
     */
    public static int getDefaultPageNumber() {
        return 0;
    }

    /**
     * Default page size (30 rows per page)
     */
    public static int getDefaultPageSize() {
        return 30;
    }

    /**
     * Maximum page size allowed
     */
    public static int getMaxPageSize() {
        return 100;
    }

    /**
     * Ensure page size is within valid bounds
     */
    public static int validatePageSize(Integer pageSize) {
        if (pageSize == null || pageSize <= 0) {
            return getDefaultPageSize();
        }
        return Math.min(pageSize, getMaxPageSize());
    }

    /**
     * Ensure page number is valid
     */
    public static int validatePageNumber(Integer pageNumber) {
        if (pageNumber == null || pageNumber < 0) {
            return getDefaultPageNumber();
        }
        return pageNumber;
    }
}
