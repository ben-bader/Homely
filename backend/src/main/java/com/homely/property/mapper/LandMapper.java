package com.homely.property.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.property.dto.LandCreateRequest;
import com.homely.property.dto.LandDto;
import com.homely.property.entity.Land;

@Mapper(componentModel = "spring")
public interface LandMapper {

    LandDto toDto(Land entity);

    @Mapping(target = "propertyId", ignore = true)
    @Mapping(target = "property", ignore = true)
    Land toEntity(LandCreateRequest request);
}
