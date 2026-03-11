package com.homely.user.mapper;

import org.mapstruct.Mapper;

import com.homely.user.dto.UserDto;
import com.homely.user.entity.User;

@Mapper(componentModel = "spring")
public interface UserMapper {

    @org.mapstruct.Mapping(target = "createdAt", source = "createdAt")
    @org.mapstruct.Mapping(target = "updatedAt", source = "updatedAt")
    UserDto toDto(User entity);
}
