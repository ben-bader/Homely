package com.homely.property.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.property.dto.VillaCreateRequest;
import com.homely.property.dto.VillaDto;
import com.homely.property.entity.Villa;

@Mapper(componentModel = "spring")
public interface VillaMapper {

    VillaDto toDto(Villa entity);

    @Mapping(target = "propertyId", ignore = true)
    @Mapping(target = "property", ignore = true)
    Villa toEntity(VillaCreateRequest request);
}
