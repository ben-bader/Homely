package com.homely.propertyview.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.property.entity.Property;
import com.homely.propertyview.dto.PropertyViewCreateRequest;
import com.homely.propertyview.dto.PropertyViewDto;
import com.homely.propertyview.entity.PropertyView;
import com.homely.propertyview.service.PropertyViewService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/property-views")
@RequiredArgsConstructor
public class PropertyViewController {

    private final PropertyViewService propertyViewService;

    @PostMapping
    public PropertyViewDto create(@RequestBody PropertyViewCreateRequest request) {
        PropertyView propertyView = new PropertyView();
        Property property = new Property();
        property.setId(request.getPropertyId());
        propertyView.setProperty(property);
        propertyView.setIpAddress(request.getIpAddress());
        return convertToDto(propertyViewService.create(propertyView));
    }

    @GetMapping("/{id}")
    public PropertyViewDto get(@PathVariable UUID id) {
        return convertToDto(propertyViewService.get(id));
    }

    @GetMapping
    public List<PropertyViewDto> getAll() {
        return propertyViewService.getAll().stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/property/{propertyId}")
    public List<PropertyViewDto> getByProperty(@PathVariable UUID propertyId) {
        return propertyViewService.getByProperty(propertyId).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/user/{userId}")
    public List<PropertyViewDto> getByUser(@PathVariable UUID userId) {
        return propertyViewService.getByUser(userId).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/property/{propertyId}/count")
    public long countByProperty(@PathVariable UUID propertyId) {
        return propertyViewService.countByProperty(propertyId);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable UUID id) {
        propertyViewService.delete(id);
    }

    private PropertyViewDto convertToDto(PropertyView propertyView) {
        PropertyViewDto dto = new PropertyViewDto();
        dto.setId(propertyView.getId());
        dto.setUserId(propertyView.getUser() != null ? propertyView.getUser().getId() : null);
        dto.setPropertyId(propertyView.getProperty().getId());
        dto.setIpAddress(propertyView.getIpAddress());
        return dto;
    }
}