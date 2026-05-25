package com.homely.auth.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class UserResponse {
    private String id;
    private String name;
    private String email;
    private List<String> roles;
    private boolean verified;
    private String avatarUrl;
}
