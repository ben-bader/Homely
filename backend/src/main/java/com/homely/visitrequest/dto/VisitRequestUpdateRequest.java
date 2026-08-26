package com.homely.visitrequest.dto;

import java.time.LocalDateTime;
import com.homely.common.enums.VisitStatus;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VisitRequestUpdateRequest {
    private LocalDateTime requestedDate;
    private VisitStatus status;
}
