package com.homely.moderation.dto;

import java.util.UUID;
import com.homely.common.enums.ReportStatus;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReportUpdateRequest {
    private ReportStatus status;
    private UUID reviewedByAdminId;
}
