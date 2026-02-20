package com.homely.user.dto;

import java.util.UUID;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProfileDto {
    private UUID userId;
    private String bio;
    private String address;
    private boolean verified;
    private String avtarUrl;
    private String idDocumentUrl;
}
