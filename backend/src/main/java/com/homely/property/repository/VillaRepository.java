package com.homely.property.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.property.entity.Villa;

public interface VillaRepository extends JpaRepository<Villa, UUID>  {
    
}
