package com.homely.property.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.property.entity.House;

public interface HouseRepository extends JpaRepository<House, UUID> {
    
}
