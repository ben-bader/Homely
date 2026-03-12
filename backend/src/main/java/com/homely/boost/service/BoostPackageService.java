package com.homely.boost.service;

import com.homely.boost.entity.BoostPackage;
import com.homely.boost.dto.BoostPackageDto;
import com.homely.boost.mapper.BoostPackageMapper;
import com.homely.boost.repository.BoostPackageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BoostPackageService {
    private final BoostPackageRepository repository;
    private final BoostPackageMapper mapper;

    public List<BoostPackageDto> getAllPackages() {
        return repository.findAll().stream().map(mapper::toDto).collect(Collectors.toList());
    }

    public BoostPackageDto addPackage(BoostPackageDto dto) {
        BoostPackage entity = mapper.toEntity(dto);
        return mapper.toDto(repository.save(entity));
    }

    public void deletePackage(Long id) {
        repository.deleteById(id);
    }
}