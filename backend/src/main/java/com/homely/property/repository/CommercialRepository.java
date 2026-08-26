package com.homely.property.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.property.entity.Commercial;

public interface CommercialRepository extends JpaRepository<Commercial, UUID>{
    
}
