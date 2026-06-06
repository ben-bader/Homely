package com.homely.analytics.service;

import com.homely.analytics.dto.ChatAnalyticsResponse;
import com.homely.analytics.dto.EngagementAnalyticsResponse;
import com.homely.analytics.dto.MediaStatsResponse;
import com.homely.analytics.dto.ModerationAnalyticsResponse;
import com.homely.analytics.dto.OverviewStatsResponse;
import com.homely.analytics.dto.PropertyAnalyticsResponse;
import com.homely.analytics.dto.RevenueAnalyticsResponse;
import com.homely.analytics.dto.UserGrowthResponse;

public interface AdminAnalyticsService {
    OverviewStatsResponse getOverviewStats();
    UserGrowthResponse getUserGrowthStats();
    PropertyAnalyticsResponse getPropertyStats();
    RevenueAnalyticsResponse getRevenueStats();
    ChatAnalyticsResponse getChatStats();
    EngagementAnalyticsResponse getEngagementStats();
    ModerationAnalyticsResponse getModerationStats();
    MediaStatsResponse getMediaStats();
}
