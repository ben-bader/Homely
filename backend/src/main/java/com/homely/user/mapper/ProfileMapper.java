package com.homely.user.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.user.dto.ProfileDto;
import com.homely.user.dto.ProfileUpdateRequest;
import com.homely.user.entity.Profile;

@Mapper(componentModel = "spring")
public interface ProfileMapper {

    @Mapping(target = "userId", source = "userId")
    ProfileDto toDto(Profile entity);

    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "verified", ignore = true)
    void updateFromRequest(ProfileUpdateRequest request, @org.mapstruct.MappingTarget Profile profile);
}
