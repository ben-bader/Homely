package com.homely.property.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.property.service.FeaturedPropertiesSettingService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/featured-properties-setting")
@RequiredArgsConstructor
public class FeaturedPropertiesSettingController {
    private final FeaturedPropertiesSettingService service;

    @GetMapping
    public int getFeaturedCount() {
        return service.getFeaturedCount();
    }

    @PostMapping
    public int setFeaturedCount(@RequestParam int count) {
        return service.setFeaturedCount(count).getFeaturedCount();
    }
}
