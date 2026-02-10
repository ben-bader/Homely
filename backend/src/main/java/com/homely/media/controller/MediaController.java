package com.homely.media.controller;

import java.util.UUID;

import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.media.dto.PropertyMediaCreateRequest;
import com.homely.media.dto.PropertyMediaDto;
import com.homely.media.entity.PropertyMedia;
import com.homely.media.service.MediaService;
import com.homely.property.entity.Property;

import lombok.RequiredArgsConstructor;


@RestController
@RequestMapping("/api/media")
@RequiredArgsConstructor
public class MediaController {

    private final MediaService mediaService;

    @PostMapping
    public PropertyMediaDto upload(@RequestBody PropertyMediaCreateRequest request) {
        PropertyMedia media = new PropertyMedia();
        Property property = new Property();
        property.setId(request.getPropertyId());
        media.setProperty(property);
        media.setMediaType(request.getMediaType());
        media.setUrl(request.getUrl());
        media.setThumbnailUrl(request.getThumbnailUrl());
        media.setDisplayOrder(request.getDisplayOrder());
        media.setDurationSeconds(request.getDurationSeconds());
        return convertToDto(mediaService.add(media));
    }
    @PutMapping("/{id}")
    public void putMethodName(@PathVariable UUID property_id) {
        mediaService.delete(property_id);
    }

    private PropertyMediaDto convertToDto(PropertyMedia media) {
        PropertyMediaDto dto = new PropertyMediaDto();
        dto.setId(media.getId());
        dto.setPropertyId(media.getProperty().getId());
        dto.setMediaType(media.getMediaType());
        dto.setUrl(media.getUrl());
        dto.setThumbnailUrl(media.getThumbnailUrl());
        dto.setDisplayOrder(media.getDisplayOrder());
        dto.setDurationSeconds(media.getDurationSeconds());
        return dto;
    }
}
