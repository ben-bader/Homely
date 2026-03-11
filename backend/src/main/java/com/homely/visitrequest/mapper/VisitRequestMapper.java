package com.homely.visitrequest.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.visitrequest.dto.VisitRequestCreateRequest;
import com.homely.visitrequest.dto.VisitRequestDto;
import com.homely.visitrequest.entity.VisitRequest;

@Mapper(componentModel = "spring")
public interface VisitRequestMapper {

    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "propertyId", source = "property.id")
    @Mapping(source = "user.name", target = "userName")
    @Mapping(source = "user.email", target = "userEmail")
    @Mapping(source = "property.title", target = "propertyTitle")
    @Mapping(target = "createdAt", source = "createdAt")
    @Mapping(target = "updatedAt", source = "updatedAt")
    VisitRequestDto toDto(VisitRequest entity);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "property", ignore = true)
    @Mapping(target = "status", ignore = true)
    VisitRequest toEntity(VisitRequestCreateRequest request);
}
