package com.homely.media.service;

import java.io.IOException;
import java.util.UUID;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.HttpHeaders;
import org.springframework.beans.factory.annotation.Value;

import org.springframework.http.MediaType;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SupabaseStorageService {


     @Value("${supabase.url}")
    private String supabaseUrl;

    @Value("${supabase.service.key}")
    private String serviceKey;
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
