package com.homely.user.dto;

import java.util.UUID;

import com.homely.common.enums.RoleType;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Getter
@Setter

public class UserDto {
    private UUID id;
    private String email;
    private String name;
    private String phone;
    private RoleType role;
    private boolean isActive;
}
