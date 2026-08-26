package com.homely.auth.dto;

import com.homely.common.enums.RoleType;

import jakarta.validation.constraints.Email;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class RegisterRequest {
    @Email
    private String email;
    private String password;
    private String name;
    private String phone;
    private RoleType role;
}
