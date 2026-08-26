package com.homely.propertyview.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.propertyview.dto.PropertyViewCreateRequest;
import com.homely.propertyview.dto.PropertyViewDto;
import com.homely.propertyview.entity.PropertyView;

@Mapper(componentModel = "spring")
public interface PropertyViewMapper {

    @Mapping(target = "userId", expression = "java(entity.getUser() != null ? entity.getUser().getId() : null)")
    @Mapping(target = "propertyId", source = "property.id")
    @Mapping(target = "createdAt", source = "createdAt")
    @Mapping(target = "updatedAt", source = "updatedAt")
    PropertyViewDto toDto(PropertyView entity);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "property", ignore = true)
    PropertyView toEntity(PropertyViewCreateRequest request);
}
