package com.homely.favorite.dto;

import java.time.Instant;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@RequiredArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class FavoriteDto {

    private UUID id;
    private UUID userId;
    private UUID propertyId;
    private UUID mediaId;
    private Instant createdAt;
    private Instant updatedAt;

}