package com.homely.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.fasterxml.jackson.databind.ObjectMapper;

@Configuration
public class AppConfig {

    @Value("${app.frontend.url:http://localhost:3000}")
    private String frontendUrl;

    @Value("${app.mobile-deeplink.url:homely://reset}")
    private String mobileDeepLinkUrl;

    public String getFrontendUrl() {
        return frontendUrl;
    }

    public String getMobileDeepLinkUrl() {
        return mobileDeepLinkUrl;
    }
    
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}