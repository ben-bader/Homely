package com.homely.moderation.entity;

import java.util.UUID;

import com.homely.common.base.BaseEntity;
import com.homely.user.entity.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class LogActivity extends BaseEntity {

    @ManyToOne
    private User user;

    @Enumerated(EnumType.STRING)
    private ActivityType activityType;

    @Enumerated(EnumType.STRING)
    private EntityType entityType;

    private UUID entityId;

    private String description;

    @Column(columnDefinition = "TEXT")
    private String changes; // JSON containing before/after changes

    public enum ActivityType {
        LOGIN,
        LOGOUT,
        SIGNUP,
        PASSWORD_RESET_REQUESTED,
        PASSWORD_RESET_COMPLETED,
        VERIFY_EMAIL_REQUESTED,
        VERIFY_EMAIL_COMPLETED,
        CREATE,
        UPDATE,
        DELETE,
        SUSPEND,
        REACTIVATE,
        APPROVE,
        REJECT,
        REPORT_FILED,
        REPORT_STATUS_CHANGED
    }

    public enum EntityType {
        USER,
        PROPERTY,
        REPORT,
        ADMIN_ACTION,
        SELLER_ACTION,
        BUYER_ACTION
    }
}
