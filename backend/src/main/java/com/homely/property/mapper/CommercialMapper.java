package com.homely.property.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.property.dto.CommercialCreateRequest;
import com.homely.property.dto.CommercialDto;
import com.homely.property.entity.Commercial;

@Mapper(componentModel = "spring")
public interface CommercialMapper {

    CommercialDto toDto(Commercial entity);

    @Mapping(target = "propertyId", ignore = true)
    @Mapping(target = "property", ignore = true)
    Commercial toEntity(CommercialCreateRequest request);
}
