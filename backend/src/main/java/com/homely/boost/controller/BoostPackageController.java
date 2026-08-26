package com.homely.boost.controller;

import com.homely.boost.dto.BoostPackageDto;
import com.homely.boost.service.BoostPackageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/boost/packages")
@RequiredArgsConstructor
public class BoostPackageController {
    private final BoostPackageService service;

    // For mobile frontend
    @GetMapping
    public List<BoostPackageDto> getAllPackages() {
        return service.getAllPackages();
    }

    // For admin
    @PostMapping
    public BoostPackageDto addPackage(@RequestBody BoostPackageDto dto) {
        return service.addPackage(dto);
    }

    @DeleteMapping("/{id}")
    public void deletePackage(@PathVariable Long id) {
        service.deletePackage(id);
    }
}