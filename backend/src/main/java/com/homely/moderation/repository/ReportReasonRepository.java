package com.homely.moderation.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.moderation.entity.ReportReason;

public interface ReportReasonRepository extends JpaRepository<ReportReason, UUID> {
    /**
     * Find all active report reasons
     * @return list of active report reasons
     */
    List<ReportReason> findByActiveTrue();

    /**
     * Find all inactive report reasons
     * @return list of inactive report reasons
     */
    List<ReportReason> findByActiveFalse();
}
