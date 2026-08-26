package com.homely.property.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.property.dto.ApartmentCreateRequest;
import com.homely.property.dto.ApartmentDto;
import com.homely.property.entity.Apartment;

@Mapper(componentModel = "spring")
public interface ApartmentMapper {

    ApartmentDto toDto(Apartment entity);

    @Mapping(target = "propertyId", ignore = true)
    @Mapping(target = "property", ignore = true)
    Apartment toEntity(ApartmentCreateRequest request);
}
