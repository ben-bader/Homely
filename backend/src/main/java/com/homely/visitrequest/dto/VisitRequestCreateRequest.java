package com.homely.visitrequest.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VisitRequestCreateRequest {

    @NotNull
    private UUID propertyId;
    @NotNull
    private LocalDateTime requestedDate;
}
