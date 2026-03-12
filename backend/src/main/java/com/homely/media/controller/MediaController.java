package com.homely.media.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.homely.media.service.MediaService;
import com.homely.property.repository.PropertyRepository;

import lombok.RequiredArgsConstructor;

import com.homely.media.dto.PropertyMediaDto;
import com.homely.media.entity.PropertyMedia;
import com.homely.media.mapper.PropertyMediaMapper;
import java.util.UUID;
import java.util.List;
import java.io.IOException;

@RestController
@RequestMapping("/api/media")
@RequiredArgsConstructor
public class MediaController {

    private final MediaService mediaService;
    private final PropertyMediaMapper propertyMediaMapper;
    private final PropertyRepository propertyRepository;



    // ─────────────────────────────────────────────────────────────────
    // POST /api/media/upload
    // Upload one or more images and/or videos for a property
    // ─────────────────────────────────────────────────────────────────
    @PostMapping(value = "/upload", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PropertyMediaDto> uploadMedia(
            @RequestParam UUID propertyId,
            @RequestParam MultipartFile file,
            @RequestParam boolean isVideo) {

        PropertyMedia media = new PropertyMedia();
        com.homely.common.enums.MediaType mediaType = isVideo ? com.homely.common.enums.MediaType.VIDEO : com.homely.common.enums.MediaType.IMAGE;
        media.setMediaType(mediaType);
        media.setProperty(propertyRepository.findById(propertyId).orElseThrow(() -> new RuntimeException("Property not found: " + propertyId)));
        mediaService.save(media);

        PropertyMediaDto dto = propertyMediaMapper.toDto(media);
        return ResponseEntity.ok(dto);
    }

    // ─────────────────────────────────────────────────────────────────
    // GET /api/media/{propertyId}
    // Returns all media for a given property
    // ─────────────────────────────────────────────────────────────────
    @GetMapping("/{propertyId}")
    public ResponseEntity<List<PropertyMediaDto>> getMedia(@PathVariable UUID propertyId) {
        List<PropertyMediaDto> mediaList = mediaService.findByPropertyId(propertyId);

        return ResponseEntity.ok(mediaList);
    }

    // ─────────────────────────────────────────────────────────────────
    // DELETE /api/media/{id}
    // Delete a single media record and remove it from storage
    // ─────────────────────────────────────────────────────────────────
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) throws IOException {
        mediaService.delete(id);
        return ResponseEntity.noContent().build();
    }
}