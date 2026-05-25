package com.homely.auth.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PasswordResetSubmitRequest {
    private String token;
    private String newPassword;
}
