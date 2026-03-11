package com.homely.property.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.property.entity.FeaturedPropertiesSetting;

public interface FeaturedPropertiesSettingRepository extends JpaRepository<FeaturedPropertiesSetting, Long> {
}
