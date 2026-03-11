package com.homely.moderation.controller;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.moderation.entity.ReportReason;
import com.homely.moderation.service.ReportReasonService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/report-reasons")
@RequiredArgsConstructor
public class ReportReasonController {
    private final ReportReasonService reportReasonService;

    @GetMapping
    public List<ReportReason> getAllReasons() {
        return reportReasonService.getAllReasons();
    }

    @PostMapping
    public ReportReason addReason(@RequestParam String reason) {
        return reportReasonService.addReason(reason);
    }

    @DeleteMapping("/{id}")
    public void deleteReason(@PathVariable Long id) {
        reportReasonService.deleteReason(id);
    }
}
