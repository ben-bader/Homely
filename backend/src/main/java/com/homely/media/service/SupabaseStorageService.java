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
    @Autowired
    public SupabaseStorageService(Dotenv dotenv) {
        this.supabaseUrl = dotenv.get("SUPABASE_URL");
        this.serviceKey = dotenv.get("SUPABASE_SERVICE_KEY");
    }
    private final RestTemplate restTemplate = new RestTemplate();

    public String uploadVideo(MultipartFile file, UUID propertyId) throws IOException {

        String path = "property-" + propertyId + "/" + UUID.randomUUID() + ".mp4";

        String uploadUrl = supabaseUrl + "/storage/v1/object/property-videos/" + path;

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(serviceKey);
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);

        HttpEntity<byte[]> entity =
                new HttpEntity<>(file.getBytes(), headers);

        restTemplate.exchange(uploadUrl, HttpMethod.POST, entity, String.class);

        return supabaseUrl + "/storage/v1/object/public/property-videos/" + path;
    }
}
