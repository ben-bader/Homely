package com.homely.moderation.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.moderation.entity.ReportReason;

public interface ReportReasonRepository extends JpaRepository<ReportReason, Long> {
}
