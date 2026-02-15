package com.homely.media.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.media.dto.PropertyMediaCreateRequest;
import com.homely.media.dto.PropertyMediaDto;
import com.homely.media.entity.PropertyMedia;

@Mapper(componentModel = "spring")
public interface PropertyMediaMapper {

    @Mapping(target = "propertyId", source = "property.id")
    PropertyMediaDto toDto(PropertyMedia entity);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "property", ignore = true)
    PropertyMedia toEntity(PropertyMediaCreateRequest request);
}
