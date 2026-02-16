package com.homely.media.dto;

import org.springframework.web.multipart.MultipartFile;

public record VideoUploadRequest(
        Long propertyId,
        MultipartFile file,
        int displayOrder
) {}
