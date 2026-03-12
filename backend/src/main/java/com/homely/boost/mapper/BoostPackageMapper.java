package com.homely.boost.mapper;

import com.homely.boost.entity.BoostPackage;
import com.homely.boost.dto.BoostPackageDto;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface BoostPackageMapper {
    BoostPackageDto toDto(BoostPackage entity);
    BoostPackage toEntity(BoostPackageDto dto);
}