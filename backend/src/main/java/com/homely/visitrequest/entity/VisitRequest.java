package com.homely.visitrequest.entity;

import java.time.LocalDateTime;

import com.homely.common.base.BaseEntity;
import com.homely.common.enums.VisitStatus;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "visit_requests")
@Getter
@Setter
public class VisitRequest extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private com.homely.user.entity.User user;

    @ManyToOne
    @JoinColumn(name = "property_id", nullable = false)
    private com.homely.property.entity.Property property;

    @Column(nullable = false)
    private LocalDateTime requestedDate;

    @Enumerated(EnumType.STRING)
    private VisitStatus status; // e.g., PENDING, APPROVED, REJECTED
}