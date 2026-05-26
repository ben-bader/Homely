package com.homely.analytics.dto;

import java.util.List;
import java.util.Map;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatAnalyticsResponse {
    private long totalConversations;
    private Map<String, Long> messagesPerDay;
    private long activeChats;
    private List<UserActivityDto> mostActiveUsers;
}
