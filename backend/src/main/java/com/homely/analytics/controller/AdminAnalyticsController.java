package com.homely.analytics.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.analytics.dto.ChatAnalyticsResponse;
import com.homely.analytics.dto.EngagementAnalyticsResponse;
import com.homely.analytics.dto.MediaStatsResponse;
import com.homely.analytics.dto.ModerationAnalyticsResponse;
import com.homely.analytics.dto.OverviewStatsResponse;
import com.homely.analytics.dto.PropertyAnalyticsResponse;
import com.homely.analytics.dto.RevenueAnalyticsResponse;
import com.homely.analytics.dto.UserGrowthResponse;
import com.homely.analytics.service.AdminAnalyticsService;

@RestController
@RequestMapping("/api/admin/stats")
@PreAuthorize("hasRole('ADMIN')")
public class AdminAnalyticsController {

    @Autowired
    private AdminAnalyticsService adminAnalyticsService;

    @GetMapping("/overview")
    public OverviewStatsResponse getOverview() {
        return adminAnalyticsService.getOverviewStats();
    }

    @GetMapping("/users-growth")
    public UserGrowthResponse getUserGrowth() {
        return adminAnalyticsService.getUserGrowthStats();
    }

    @GetMapping("/properties")
    public PropertyAnalyticsResponse getProperties() {
        return adminAnalyticsService.getPropertyStats();
    }

    @GetMapping("/revenue")
    public RevenueAnalyticsResponse getRevenue() {
        return adminAnalyticsService.getRevenueStats();
    }

    @GetMapping("/chats")
    public ChatAnalyticsResponse getChats() {
        return adminAnalyticsService.getChatStats();
    }

    @GetMapping("/engagement")
    public EngagementAnalyticsResponse getEngagement() {
        return adminAnalyticsService.getEngagementStats();
    }

    @GetMapping("/moderation")
    public ModerationAnalyticsResponse getModeration() {
        return adminAnalyticsService.getModerationStats();
    }

    @GetMapping("/media")
    public MediaStatsResponse getMedia() {
        return adminAnalyticsService.getMediaStats();
    }
}
