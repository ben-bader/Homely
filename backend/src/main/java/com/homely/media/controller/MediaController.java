package com.homely.media.controller;

import java.util.Map;
import java.util.UUID;
import java.io.IOException;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import com.homely.common.enums.MediaType;
import com.homely.media.dto.PropertyMediaCreateRequest;
import com.homely.media.dto.PropertyMediaDto;
import com.homely.media.entity.PropertyMedia;
import com.homely.media.repository.PropertyMediaRepository;
import com.homely.media.service.MediaService;
import com.homely.media.service.SupabaseStorageService;
import com.homely.property.entity.Property;
import com.homely.property.repository.PropertyRepository;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/media")
@RequiredArgsConstructor
public class MediaController {

        private final MediaService mediaService;
        private final SupabaseStorageService storageService;
        private final PropertyRepository propertyRepository;
        private final PropertyMediaRepository mediaRepository;

        @Value("${supabase.url}")
        private String supabaseUrl;

        @Value("${supabase.service-role-key}")
        private String serviceRoleKey;

        @Value("${supabase.bucket}")
        private String bucket;

        @GetMapping("/{propertyId}/media")
        public List<PropertyMedia> getMedia(@PathVariable UUID propertyId) {
                return mediaService.findByPropertyId(propertyId);
        }

        @PostMapping
        public PropertyMediaDto create(@Valid @RequestBody PropertyMediaCreateRequest request) {
                return mediaService.create(request);
        }

        @DeleteMapping("/{id}")
        public void delete(@PathVariable UUID id) {
                mediaService.delete(id);
        }
        
        @PostMapping("/upload")
        public ResponseEntity<?> uploadVideo(
                        @RequestParam UUID propertyId,
                        @RequestParam MultipartFile file,
                        @RequestParam int displayOrder) throws IOException {

                Property property = propertyRepository.findById(propertyId)
                                .orElseThrow();

                String videoUrl = storageService.uploadVideo(file, propertyId);

                PropertyMedia media = new PropertyMedia();
                media.setProperty(property);
                media.setMediaType(MediaType.VIDEO);
                media.setUrl(videoUrl);
                media.setDisplayOrder(displayOrder);

                mediaRepository.save(media);

                return ResponseEntity.ok(videoUrl);
        }
}
