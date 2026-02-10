package com.homely.visitrequest.dto;

import java.time.LocalDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VisitRequestCreateRequest {
    private UUID propertyId;
    private LocalDateTime requestedDate;
}
