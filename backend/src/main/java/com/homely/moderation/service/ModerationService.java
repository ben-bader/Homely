package com.homely.moderation.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.common.enums.ReportStatus;
import com.homely.moderation.entity.AuditLog;
import com.homely.moderation.entity.LogActivity;
import com.homely.moderation.entity.Report;
import com.homely.moderation.entity.ReportReason;
import com.homely.moderation.repository.AuditLogRepository;
import com.homely.moderation.repository.ReportReasonRepository;
import com.homely.moderation.repository.ReportRepository;
import com.homely.user.entity.User;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ModerationService {

    private final ReportRepository reportRepository;
    private final ReportReasonRepository reportReasonRepository;
    private final AuditLogRepository auditLogRepository;
    private final LogActivityService logActivityService;

    /**
     * Save a new report with validation that the selected reason is active
     * 
     * @param report the report to save
     * @return the saved report
     * @throws IllegalArgumentException if report reason is null or inactive
     */
    public Report report(Report report) {
        validateReportReason(report);
        return reportRepository.save(report);
    }

    /**
     * Validate that a report has a valid and active reason
     * 
     * @param report the report to validate
     * @throws IllegalArgumentException if report reason is null or inactive
     */
    private void validateReportReason(Report report) {
        if (report.getReportReason() == null) {
            throw new IllegalArgumentException("Report must have a reason selected");
        }
        
        ReportReason reason = reportReasonRepository.findById(report.getReportReason().getId())
            .orElseThrow(() -> new IllegalArgumentException("Selected report reason does not exist"));
        
        if (!reason.isActive()) {
            throw new IllegalArgumentException("Selected report reason is no longer available");
        }
    }

    /**
     * Get all active report reasons for display to users
     * 
     * @return list of active report reasons
     */
    public List<ReportReason> getActiveReportReasons() {
        return reportReasonRepository.findByActiveTrue();
    }

    public List<Report> getReports() {
        return reportRepository.findAll();
    }

    public Report getReportById(UUID id) {
        return reportRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Report not found: " + id));
    }

    public Report updateReportStatus(UUID reportId, ReportStatus newStatus, User admin) {
        Report report = getReportById(reportId);
        ReportStatus oldStatus = report.getStatus();
        report.setStatus(newStatus);
        report.setReviewedByAdmin(admin);
        Report saved = reportRepository.save(report);
        String details = String.format(
                "{\"reportId\":\"%s\",\"oldStatus\":\"%s\",\"newStatus\":\"%s\"}",
                reportId, oldStatus, newStatus);
        logAction("REPORT_STATUS_CHANGED", admin, details);
        
        // Log the activity in the new system
        logActivityService.log(
            admin,
            LogActivity.ActivityType.REPORT_STATUS_CHANGED,
            LogActivity.EntityType.REPORT,
            reportId,
            "Changed report status from " + oldStatus + " to " + newStatus,
            details
        );
        
        return saved;
    }

    public void logAction(String action, User admin) {
        logAction(action, admin, null);
    }
    @Transactional
    public void logAction(String action, User admin, String details) {
        var log = new AuditLog();
        log.setAction(action);
        log.setAdmin(admin);
        log.setDetails(details);
        auditLogRepository.save(log);
    }

    public List<AuditLog> getAllAuditLogs() {
        return auditLogRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<LogActivity> getAllLogActivities() {
        return logActivityService.getAllActivities();
    }

    public long count(){
        return reportRepository.count();
    }
}
