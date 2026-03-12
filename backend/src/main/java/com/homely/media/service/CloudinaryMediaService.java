package com.homely.media.service;
import java.io.IOException;
import java.util.*;


import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

@Service
public class CloudinaryMediaService {

    private final Cloudinary cloudinary;

    public CloudinaryMediaService(Cloudinary cloudinary) {
        this.cloudinary = cloudinary;
    }

    public String uploadFile(MultipartFile file, String propertyId) throws IOException {
        boolean isVideo = file.getContentType() != null 
                          && file.getContentType().startsWith("video/");

        Map<String, Object> options = ObjectUtils.asMap(
            // Organize files in folders by property
            "folder",          "homely/properties/" + propertyId,
            // auto = image or video
            "resource_type",   isVideo ? "video" : "image",
            // auto-compress
            "quality",         "auto",
            "fetch_format",    "auto"
        );

        Map<?, ?> result = cloudinary.uploader()
            .upload(file.getBytes(), options);

        // Cloudinary returns the public URL directly
        return (String) result.get("secure_url");
    }

    public List<String> uploadFiles(
        List<MultipartFile> files,
        String propertyId
    ) throws IOException {
        List<String> urls = new ArrayList<>();
        for (MultipartFile file : files) {
            validateFile(file);
            urls.add(uploadFile(file, propertyId));
        }
        return urls;
    }

    public void deleteFile(String publicUrl) throws IOException {
        // Extract public_id from URL
        // URL format: https://res.cloudinary.com/cloud/image/upload/v123/homely/properties/id/filename.jpg
        String publicId = extractPublicId(publicUrl);
        cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
    }

    private String extractPublicId(String url) {
        // Remove base URL and extension
        String[] parts = url.split("/upload/");
        String withVersion = parts[1]; // v1234/homely/properties/id/file.jpg
        String withoutVersion = withVersion.replaceFirst("v\\d+/", "");
        // Remove extension
        return withoutVersion.substring(0, withoutVersion.lastIndexOf('.'));
    }

    private void validateFile(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null) throw new RuntimeException("Unknown file type");

        boolean isImage = contentType.startsWith("image/");
        boolean isVideo = contentType.startsWith("video/");

        if (!isImage && !isVideo) {
            throw new RuntimeException("Only images and videos allowed");
        }

        long maxSize = isVideo
            ? 100L * 1024 * 1024   // 100MB for video
            : 10L * 1024 * 1024;   // 10MB for images

        if (file.getSize() > maxSize) {
            throw new RuntimeException("File too large");
        }
    }
}