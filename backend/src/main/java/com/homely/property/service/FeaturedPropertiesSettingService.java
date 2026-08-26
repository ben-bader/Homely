package com.homely.property.service;

import org.springframework.stereotype.Service;

import com.homely.property.entity.FeaturedPropertiesSetting;
import com.homely.property.repository.FeaturedPropertiesSettingRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class FeaturedPropertiesSettingService {
    private final FeaturedPropertiesSettingRepository repository;

    public int getFeaturedCount() {
        return repository.findAll().stream().findFirst().map(FeaturedPropertiesSetting::getFeaturedCount).orElse(5);
    }

    public FeaturedPropertiesSetting setFeaturedCount(int count) {
        FeaturedPropertiesSetting setting = repository.findAll().stream().findFirst().orElse(new FeaturedPropertiesSetting());
        setting.setFeaturedCount(count);
        return repository.save(setting);
    }
}
