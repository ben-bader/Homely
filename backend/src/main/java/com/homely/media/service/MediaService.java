package com.homely.media.service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

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

    public List<PropertyMediaDto> findByPropertyId(UUID id) {
        return mediaRepository.findByPropertyId(id)
                .stream()
                .map(propertyMediaMapper::toDto)
                .collect(Collectors.toList());
    }

     public PropertyMediaDto toDto(PropertyMedia media) {
        return propertyMediaMapper.toDto(media);
    }

   public void save(PropertyMedia media) {
        mediaRepository.save(media);
    }

  public List<PropertyMediaDto> toDtoList(List<PropertyMedia> mediaList) {
        return mediaList.stream()
                .map(propertyMediaMapper::toDto)
                .collect(Collectors.toList());
    }
}

