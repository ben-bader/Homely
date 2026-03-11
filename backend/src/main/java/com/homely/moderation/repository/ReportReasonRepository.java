package com.homely.moderation.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.moderation.entity.ReportReason;

public interface ReportReasonRepository extends JpaRepository<ReportReason, UUID> {
}
