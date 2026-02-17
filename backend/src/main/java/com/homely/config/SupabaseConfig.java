package com.homely.config;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SupabaseConfig {

    @Bean
    public Dotenv dotenv() {
        return Dotenv.load(); // loads .env from project root
    }
}

