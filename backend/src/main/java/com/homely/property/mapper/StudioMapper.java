package com.homely.property.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.property.dto.StudioCreateRequest;
import com.homely.property.dto.StudioDto;
import com.homely.property.entity.Studio;

@Mapper(componentModel = "spring")
public interface StudioMapper {

    StudioDto toDto(Studio entity);

    @Mapping(target = "propertyId", ignore = true)
    @Mapping(target = "property", ignore = true)
    Studio toEntity(StudioCreateRequest request);
}
