package com.homely.moderation.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.moderation.dto.LogActivityDto;
import com.homely.moderation.entity.LogActivity;

@Mapper(componentModel = "spring")
public interface LogActivityMapper {

    @Mapping(source = "user.id", target = "userId")
    @Mapping(source = "user.email", target = "userEmail")
    @Mapping(source = "user.name", target = "userName")
    LogActivityDto toDto(LogActivity entity);

    @Mapping(source = "userId", target = "user.id")
    LogActivity toEntity(LogActivityDto dto);
}
