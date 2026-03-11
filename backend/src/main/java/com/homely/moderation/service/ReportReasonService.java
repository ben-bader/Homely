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

    public List<ReportReason> getAllReasons() {
        return reportReasonRepository.findAll();
    }

    public ReportReason addReason(String reason) {
        ReportReason rr = new ReportReason();
        rr.setReason(reason);
        return reportReasonRepository.save(rr);
    }

    public void deleteReason(UUID id) {
        reportReasonRepository.deleteById(id);
    }
}
