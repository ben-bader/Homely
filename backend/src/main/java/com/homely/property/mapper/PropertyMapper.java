package com.homely.property.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import com.homely.property.dto.PropertyCreateRequest;
import com.homely.property.dto.PropertyDto;
import com.homely.property.entity.Property;

@Mapper(
    componentModel = "spring",
    uses = {ApartmentMapper.class, HouseMapper.class, VillaMapper.class, 
            StudioMapper.class, CommercialMapper.class, LandMapper.class}
)
public interface PropertyMapper {

    @Mapping(target = "seller", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "apartment", ignore = true)
    @Mapping(target = "house", ignore = true)
    @Mapping(target = "villa", ignore = true)
    @Mapping(target = "studio", ignore = true)
    @Mapping(target = "commercial", ignore = true)
    @Mapping(target = "land", ignore = true)
    Property toEntity(PropertyCreateRequest request);

    @Mapping(target = "sellerId", expression = "java(entity.getSeller() != null ? entity.getSeller().getId() : null)")
    PropertyDto toDto(Property entity);
}
