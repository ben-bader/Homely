package com.homely.propertyview.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.property.repository.PropertyRepository;
import com.homely.propertyview.dto.PropertyViewCreateRequest;
import com.homely.propertyview.dto.PropertyViewDto;
import com.homely.propertyview.entity.PropertyView;
import com.homely.propertyview.mapper.PropertyViewMapper;
import com.homely.propertyview.repository.PropertyViewRepository;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PropertyViewService {

    private final PropertyViewRepository propertyViewRepository;
    private final PropertyViewMapper propertyViewMapper;
    private final PropertyRepository propertyRepository;
    private final UserService userService;

    public PropertyViewDto create(PropertyViewCreateRequest request, String userEmailOrNull) {
        var property = propertyRepository.findById(request.getPropertyId())
                .orElseThrow(() -> new RuntimeException("Property not found: " + request.getPropertyId()));
        PropertyView entity = propertyViewMapper.toEntity(request);
        entity.setProperty(property);
        if (userEmailOrNull != null && !userEmailOrNull.isBlank()) {
            var user = userService.getByEmail(userEmailOrNull);
            if (user != null) entity.setUser(user);
        }
        PropertyView saved = propertyViewRepository.save(entity);
        return propertyViewMapper.toDto(saved);
    }

    public PropertyView get(UUID id) {
        return propertyViewRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("PropertyView not found"));
    }

    public List<PropertyView> getAll() {
        return propertyViewRepository.findAll();
    }

    public List<PropertyView> getByProperty(UUID propertyId) {
        return propertyViewRepository.findByPropertyId(propertyId);
    }

    public List<PropertyView> getByUser(UUID userId) {
        return propertyViewRepository.findByUserId(userId);
    }

    public long countByProperty(UUID propertyId) {
        return propertyViewRepository.countByPropertyId(propertyId);
    }

    public void delete(UUID id) {
        propertyViewRepository.deleteById(id);
    }
}