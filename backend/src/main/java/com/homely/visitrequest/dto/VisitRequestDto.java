package com.homely.visitrequest.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import com.homely.common.enums.VisitStatus;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VisitRequestDto {
    private UUID id;
    private UUID userId;
    private String userName;          // Added
    private String userEmail;          // Added
    private UUID propertyId;
    private String propertyTitle;     // Added
    private LocalDateTime requestedDate;
    private VisitStatus status;
}
