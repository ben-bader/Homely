package com.homely.user.dto;

import java.time.Instant;
import java.util.UUID;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProfileDto {

    private UUID userId;

    // 🔥 FROM USER
    private String name;
    private String email;
    private String phone;

    // 🔥 FROM PROFILE
    private String bio;
    private String address;
    private boolean verified;
    private String avatarUrl;
    private String idDocumentUrl;

    private Instant createdAt;
    private Instant updatedAt;
}