package com.homely.media.controller;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.media.dto.PropertyMediaCreateRequest;
import com.homely.media.dto.PropertyMediaDto;
import com.homely.media.mapper.PropertyMediaMapper;
import com.homely.media.service.MediaService;
import com.homely.property.repository.PropertyRepository;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/media")
@RequiredArgsConstructor
public class MediaController {

    private final MediaService mediaService;
    private final PropertyMediaMapper propertyMediaMapper;
    private final PropertyRepository propertyRepository;



  @PostMapping
    public ResponseEntity<PropertyMediaDto> saveMedia(
            @RequestBody PropertyMediaCreateRequest request) {
        return ResponseEntity.ok(mediaService.create(request));
    }
 
    @GetMapping("/{propertyId}")
    public ResponseEntity<List<PropertyMediaDto>> getMedia(@PathVariable UUID propertyId) {
        List<PropertyMediaDto> mediaList = mediaService.findByPropertyId(propertyId);

        return ResponseEntity.ok(mediaList);
    }

    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) throws IOException {
        mediaService.delete(id);
        return ResponseEntity.noContent().build();
    }
}