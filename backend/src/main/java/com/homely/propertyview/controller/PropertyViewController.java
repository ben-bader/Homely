package com.homely.propertyview.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.propertyview.dto.PropertyViewCreateRequest;
import com.homely.propertyview.dto.PropertyViewDto;
import com.homely.propertyview.mapper.PropertyViewMapper;
import com.homely.propertyview.service.PropertyViewService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/property-views")
@RequiredArgsConstructor
public class PropertyViewController {

    private final PropertyViewService propertyViewService;
    private final PropertyViewMapper propertyViewMapper;

    @PostMapping
    public PropertyViewDto create(
            @Valid @RequestBody PropertyViewCreateRequest request,
            Principal principal) {
        String userEmail = principal != null ? principal.getName() : null;
        return propertyViewService.create(request, userEmail);
    }

    @GetMapping("/{id}")
    public PropertyViewDto get(@PathVariable UUID id) {
        return propertyViewMapper.toDto(propertyViewService.get(id));
    }

    @GetMapping("/property/{propertyId}")
    public List<PropertyViewDto> getByProperty(@PathVariable UUID propertyId) {
        return propertyViewService.getByProperty(propertyId).stream()
                .map(propertyViewMapper::toDto)
                .toList();
    }

    @GetMapping("/user/{userId}")
    public List<PropertyViewDto> getByUser(@PathVariable UUID userId) {
        return propertyViewService.getByUser(userId).stream()
                .map(propertyViewMapper::toDto)
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
}