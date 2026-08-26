package com.homely.property.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.property.entity.Apartment;

public interface  ApartmentRepository extends JpaRepository<Apartment, UUID> {
    
}
