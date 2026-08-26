package com.homely.moderation.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.common.enums.ReportStatus;
import com.homely.moderation.entity.Report;

public interface ReportRepository extends JpaRepository<Report, UUID> {
    List<Report> findByStatus(ReportStatus status);

    List<Report> findByReportedUserId(UUID userId);

}
