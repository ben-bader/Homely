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
}
