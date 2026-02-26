package com.homely.media.service;

import java.io.IOException;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import io.github.cdimascio.dotenv.Dotenv;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor

public class SupabaseStorageService {

    private final String supabaseUrl;
    private final String serviceKey;
    private final String bucket;

    @Autowired
    public SupabaseStorageService(Dotenv dotenv) {
        this.supabaseUrl = dotenv.get("SUPABASE_URL");
        this.serviceKey = dotenv.get("SUPABASE_SERVICE_KEY");
        this.bucket = dotenv.get("SUPABASE_BUCKET", "property-videos");
    }

    private final RestTemplate restTemplate = new RestTemplate();

    public String uploadVideo(MultipartFile file, UUID propertyId) throws IOException {

        if (supabaseUrl == null || supabaseUrl.isBlank()) {
            throw new RuntimeException("SUPABASE_URL is not configured");
        }
        if (serviceKey == null || serviceKey.isBlank()) {
            throw new RuntimeException("SUPABASE_SERVICE_KEY is not configured");
        }

        String path = "property-" + propertyId + "/" + UUID.randomUUID() + ".mp4";

        String uploadUrl = supabaseUrl + "/storage/v1/object/" + bucket + "/" + path;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + serviceKey);
        headers.set("apikey", serviceKey); // 🔥 THIS WAS MISSING
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        HttpEntity<byte[]> entity = new HttpEntity<>(file.getBytes(), headers);

        try {
            restTemplate.exchange(uploadUrl, HttpMethod.POST, entity, String.class);
        } catch (Exception ex) {
            throw new RuntimeException("Failed to upload to Supabase storage: " + ex.getMessage(), ex);
        }

        return supabaseUrl + "/storage/v1/object/public/" + bucket + "/" + path;
    }
}
