package com.homely.propertyview.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.propertyview.entity.PropertyView;

public interface PropertyViewRepository extends JpaRepository<PropertyView, UUID> {
    List<PropertyView> findByPropertyId(UUID propertyId);
    List<PropertyView> findByUserId(UUID userId);
    long countByPropertyId(UUID propertyId);
}