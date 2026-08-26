package com.homely.property.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.property.entity.Studio;

public interface StudioRepository extends JpaRepository<Studio, UUID>{
    
}
