package com.homely.auth.dto;

import jakarta.validation.constraints.Email;
import lombok.Data;

@Data
public class PasswordResetCodeRequest {
    @Email(message = "Invalid email address")
    private String email;
}
