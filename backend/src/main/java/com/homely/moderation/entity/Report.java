package com.homely.moderation.entity;

import com.homely.common.base.BaseEntity;
import com.homely.common.enums.ReportStatus;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Report extends BaseEntity {

    @ManyToOne
    private User reporter;

    @ManyToOne
    private User reportedUser;

    @ManyToOne
    private Property reportedProperty;

    @ManyToOne(optional = false)
    private ReportReason reportReason;

    // Legacy field for backward compatibility - will be removed in future migration
    // Use reportReason instead
    @Deprecated
    private String reason;

    @Enumerated(EnumType.STRING)
    private ReportStatus status;

    @ManyToOne
    private User reviewedByAdmin;

    /**
     * Get the reason text from the ReportReason entity.
     * This method provides backward compatibility with code expecting a reason String.
     * 
     * @return the reason name, or null if reportReason is not set
     */
    public String getReasonText() {
        return reportReason != null ? reportReason.getName() : null;
    }
}
