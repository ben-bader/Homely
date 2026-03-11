package com.homely.user.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.user.dto.ProfileDto;
import com.homely.user.dto.ProfileUpdateRequest;
import com.homely.user.entity.Profile;

@Mapper(componentModel = "spring")
public interface ProfileMapper {

    // 🔥 MERGE USER + PROFILE INTO ONE DTO
    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "name", source = "user.name")
    @Mapping(target = "email", source = "user.email")
    @Mapping(target = "phone", source = "user.phone")
    @Mapping(target = "createdAt", source = "user.createdAt")
    @Mapping(target = "updatedAt", source = "user.updatedAt")
    ProfileDto toDto(Profile entity);

    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "verified", ignore = true)
    void updateFromRequest(ProfileUpdateRequest request,
                           @org.mapstruct.MappingTarget Profile profile);
}