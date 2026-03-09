package com.homely.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.IOException;

@Configuration
@Slf4j
public class FirebaseConfig {

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            try {
                // Load Firebase credentials from file
                // Place your firebase-credentials.json in src/main/resources/
                FileInputStream serviceAccount = new FileInputStream("src/main/resources/firebase-credentials.json");

                FirebaseOptions options = new FirebaseOptions.Builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                return FirebaseApp.initializeApp(options);
            } catch (IOException e) {
                log.warn("Firebase credentials file not found. Push notifications will be disabled. Error: {}", e.getMessage());
                // Don't throw exception - allow app to run without Firebase
                return null;
            }
        }
        return FirebaseApp.getInstance();
    }
}
