package com.homely.user.dto;

import com.homely.common.enums.RoleType;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserCreateRequest {
    private String email;
    private String passwordHash;
    private String name;
    private String phone;
    private RoleType role;
}
