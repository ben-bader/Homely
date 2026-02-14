package com.homely.auth.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.auth.dto.AuthResponse;
import com.homely.auth.dto.LoginRequest;
import com.homely.auth.dto.RegisterRequest;
import com.homely.auth.service.AuthService;

import lombok.RequiredArgsConstructor;


@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @PostMapping("/register")
    public AuthResponse register(@RequestBody RegisterRequest request) {
        
        return authService.register(request);
    }
    @PostMapping("/login")
    public AuthResponse login(@RequestBody LoginRequest request) {
        return authService.login(request);
    }
    
    @PostMapping("/logout")
    public void logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        authService.logout(authHeader);
    }
    
}
