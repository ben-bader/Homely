package com.homely.boost.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.boost.dto.BoostPurchaseCreateRequest;
import com.homely.boost.dto.BoostPurchaseDto;
import com.homely.boost.entity.BoostPurchase;

@Mapper(componentModel = "spring")
public interface BoostPurchaseMapper {

    @Mapping(target = "sellerId", source = "seller.id")
    @Mapping(target = "propertyId", source = "property.id")
    BoostPurchaseDto toDto(BoostPurchase entity);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "seller", ignore = true)
    @Mapping(target = "property", ignore = true)
    @Mapping(target = "status", ignore = true)
    BoostPurchase toEntity(BoostPurchaseCreateRequest request);
}
