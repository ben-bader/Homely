package com.homely.auth.controller;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/test")
public class SecurityTestController {

    @GetMapping("/whoami")
    public String whoAmI(Authentication authentication) {
        return authentication.getName();
    }
}

