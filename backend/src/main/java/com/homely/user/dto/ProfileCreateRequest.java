package com.homely.user.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProfileCreateRequest {
    private String bio;
    private String address;
    private String idDocumentUrl;
}
