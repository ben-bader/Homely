package com.homely.property.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.property.entity.Land;

public interface  LandRepository extends JpaRepository<Land, UUID>  {
    
}
