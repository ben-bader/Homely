package com.homely.media.service;

import java.util.UUID;
import java.util.List;

import org.springframework.stereotype.Service;

import com.homely.media.dto.PropertyMediaCreateRequest;
import com.homely.media.dto.PropertyMediaDto;
import com.homely.media.entity.PropertyMedia;
import com.homely.media.mapper.PropertyMediaMapper;
import com.homely.media.repository.PropertyMediaRepository;
import com.homely.property.repository.PropertyRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MediaService {

    private final PropertyMediaRepository mediaRepository;
    private final PropertyMediaMapper propertyMediaMapper;
    private final PropertyRepository propertyRepository;

    public PropertyMediaDto create(PropertyMediaCreateRequest request) {
        var property = propertyRepository.findById(request.getPropertyId())
                .orElseThrow(() -> new RuntimeException("Property not found: " + request.getPropertyId()));
        PropertyMedia entity = propertyMediaMapper.toEntity(request);
        entity.setProperty(property);
        PropertyMedia saved = mediaRepository.save(entity);
        return propertyMediaMapper.toDto(saved);
    }

    public void delete(UUID id) {
        mediaRepository.deleteById(id);
    }
    public List<PropertyMedia> findByPropertyId(UUID id){
       return mediaRepository.findByPropertyId(id);
    }
}

