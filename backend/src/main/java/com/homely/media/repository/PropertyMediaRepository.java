package com.homely.media.repository;

import java.util.*;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.media.entity.PropertyMedia;

public interface PropertyMediaRepository extends JpaRepository<PropertyMedia, UUID> {
    List<PropertyMedia> findByPropertyId(UUID propertyId);
}

