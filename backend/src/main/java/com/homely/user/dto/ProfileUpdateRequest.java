package com.homely.user.dto;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@RequiredArgsConstructor
public class ProfileUpdateRequest {
    private String bio;
    private String address;
    private String idDocumentUrl;
}
