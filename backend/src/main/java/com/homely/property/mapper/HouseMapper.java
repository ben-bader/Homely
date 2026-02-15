package com.homely.property.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.property.dto.HouseCreateRequest;
import com.homely.property.dto.HouseDto;
import com.homely.property.entity.House;

@Mapper(componentModel = "spring")
public interface HouseMapper {

    HouseDto toDto(House entity);

    @Mapping(target = "propertyId", ignore = true)
    @Mapping(target = "property", ignore = true)
    House toEntity(HouseCreateRequest request);
}
