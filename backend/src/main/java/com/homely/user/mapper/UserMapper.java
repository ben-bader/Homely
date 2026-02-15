package com.homely.user.mapper;

import org.mapstruct.Mapper;

import com.homely.user.dto.UserDto;
import com.homely.user.entity.User;

@Mapper(componentModel = "spring")
public interface UserMapper {

    UserDto toDto(User entity);
}
