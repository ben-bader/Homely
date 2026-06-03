package com.homely.moderation.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.moderation.entity.ReportReason;
import com.homely.moderation.repository.ReportReasonRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReportReasonService {
    private final ReportReasonRepository reportReasonRepository;

    /**
     * Get all report reasons (including inactive ones - for admin use)
     * @return list of all report reasons
     */
    public List<ReportReason> getAllReasons() {
        return reportReasonRepository.findAll();
    }

    /**
     * Get only active report reasons (for display to users)
     * @return list of active report reasons
     */
    public List<ReportReason> getActiveReasons() {
        return reportReasonRepository.findByActiveTrue();
    }

    /**
     * Get only inactive report reasons (for admin management)
     * @return list of inactive report reasons
     */
    public List<ReportReason> getInactiveReasons() {
        return reportReasonRepository.findByActiveFalse();
    }

    /**
     * Get a specific report reason by ID
     * @param id the reason ID
     * @return the report reason, or null if not found
     */
    public ReportReason getReasonById(UUID id) {
        return reportReasonRepository.findById(id).orElse(null);
    }

    /**
     * Create a new report reason
     * @param reason the report reason to create
     * @return the created report reason
     */
    public ReportReason addReason(ReportReason reason) {
        ReportReason rr = new ReportReason();
        rr.setReason(reason.getReason());
        rr.setName(reason.getName() != null ? reason.getName() : reason.getReason());
        rr.setActive(reason.isActive());
        rr.setDescription(reason.getDescription());
        return reportReasonRepository.save(rr);
    }

    /**
     * Update an existing report reason
     * @param id the reason ID
     * @param updatedReason the updated reason data
     * @return the updated report reason
     * @throws RuntimeException if reason not found
     */
    public ReportReason updateReason(UUID id, ReportReason updatedReason) {
        ReportReason existing = reportReasonRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Report reason not found: " + id));
        
        if (updatedReason.getName() != null) {
            existing.setName(updatedReason.getName());
        }
        if (updatedReason.getDescription() != null) {
            existing.setDescription(updatedReason.getDescription());
        }
        existing.setActive(updatedReason.isActive());
        
        return reportReasonRepository.save(existing);
    }

    /**
     * Activate a report reason
     * @param id the reason ID
     * @return the updated reason
     */
    public ReportReason activateReason(UUID id) {
        ReportReason reason = reportReasonRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Report reason not found: " + id));
        reason.setActive(true);
        return reportReasonRepository.save(reason);
    }

    /**
     * Deactivate a report reason
     * @param id the reason ID
     * @return the updated reason
     */
    public ReportReason deactivateReason(UUID id) {
        ReportReason reason = reportReasonRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Report reason not found: " + id));
        reason.setActive(false);
        return reportReasonRepository.save(reason);
    }

    /**
     * Delete a report reason permanently
     * @param id the reason ID
     */
    public void deleteReason(UUID id) {
        reportReasonRepository.deleteById(id);
    }
}
