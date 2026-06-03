package com.homely.moderation.entity;

import com.homely.common.base.BaseEntity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class ReportReason extends BaseEntity {
    
    @Column(nullable = false, unique = true)
    private String reason;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(nullable = false)
    private boolean active = true;

    @Column(length = 1024)
    private String description;

    /**
     * Default constructor - required by JPA
     */
    public ReportReason() {
    }

    /**
     * Constructor for creating a new report reason
     * @param reason the reason code/identifier (for backward compatibility)
     * @param name the display name of the reason
     * @param active whether this reason is currently active
     */
    public ReportReason(String reason, String name, boolean active) {
        this.reason = reason;
        this.name = name;
        this.active = active;
    }

    /**
     * Constructor for creating a new report reason with description
     * @param reason the reason code/identifier
     * @param name the display name
     * @param active whether this reason is currently active
     * @param description additional description
     */
    public ReportReason(String reason, String name, boolean active, String description) {
        this.reason = reason;
        this.name = name;
        this.active = active;
        this.description = description;
    }
}

