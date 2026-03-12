package com.homely.media.service;

import java.io.IOException;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.google.firebase.cloud.StorageClient;

@Service
public class FirebaseStorageService {

    public String uploadVideo(MultipartFile file, UUID propertyId) throws IOException {
        return uploadFile(file, propertyId, "mp4");
    }

    public String uploadImage(MultipartFile file, UUID propertyId) throws IOException {
        return uploadFile(file, propertyId, "jpg");
    }

    private String uploadFile(MultipartFile file, UUID propertyId, String extension) throws IOException {
        String path = "property-" + propertyId + "/" + UUID.randomUUID() + "." + extension;

        try {
            StorageClient.getInstance().bucket().create(path, file.getInputStream(), file.getContentType());
        } catch (IOException ex) {
            throw new IOException("Failed to upload to Firebase storage: " + ex.getMessage(), ex);
        } catch (Exception ex) {
            throw new RuntimeException("Unexpected error during upload: " + ex.getMessage(), ex);
        }

        return "https://storage.googleapis.com/" + StorageClient.getInstance().bucket().getName() + "/" + path;
    }
}
