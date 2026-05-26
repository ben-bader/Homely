package com.homely.analytics.service;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.Instant;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.homely.analytics.dto.AdminActivityDto;
import com.homely.analytics.dto.AuditLogItem;
import com.homely.analytics.dto.ChatAnalyticsResponse;
import com.homely.analytics.dto.EngagementAnalyticsResponse;
import com.homely.analytics.dto.ModerationAnalyticsResponse;
import com.homely.analytics.dto.OverviewStatsResponse;
import com.homely.analytics.dto.PropertyAnalyticsResponse;
import com.homely.analytics.dto.PropertyPerformanceDto;
import com.homely.analytics.dto.RevenueAnalyticsResponse;
import com.homely.analytics.dto.SellerRevenueDto;
import com.homely.analytics.dto.UserActivityDto;
import com.homely.analytics.dto.UserGrowthResponse;
import com.homely.analytics.repository.AnalyticsRepository;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.RoleType;
import com.homely.moderation.entity.LogActivity;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

@Service
@Transactional(readOnly = true)
public class AdminAnalyticsServiceImpl implements AdminAnalyticsService {

    @Autowired
    private AnalyticsRepository analyticsRepository;

    @Override
    public OverviewStatsResponse getOverviewStats() {
        long totalUsers = analyticsRepository.countUsers();
        long totalProperties = analyticsRepository.countProperties();
        long totalPendingProperties = analyticsRepository.countPropertiesByStatus(PropertyStatus.DRAFT);
        long totalApprovedProperties = analyticsRepository.countPropertiesByStatus(PropertyStatus.AVAILABLE);
        long totalRejectedProperties = analyticsRepository.countPropertiesByStatus(PropertyStatus.SUSPENDED);
        long totalSoldProperties = 0; // default safe fallback

        long totalChats = analyticsRepository.countConversations();
        long totalMessages = analyticsRepository.countMessages();
        long totalFavorites = analyticsRepository.countFavorites();
        long totalNotifications = analyticsRepository.countNotifications();
        long totalReports = analyticsRepository.countReports();
        long totalBoostPurchases = analyticsRepository.countBoostPurchases();
        BigDecimal totalRevenue = analyticsRepository.sumBoostRevenue();

        Instant todayStart = Instant.now().minus(java.time.Duration.ofDays(1));
        Instant weekStart = Instant.now().minus(java.time.Duration.ofDays(7));
        Instant monthStart = Instant.now().minus(java.time.Duration.ofDays(30));

        long activeUsersToday = analyticsRepository.countActiveUsersSince(todayStart);
        long activeUsersThisWeek = analyticsRepository.countActiveUsersSince(weekStart);
        long activeUsersThisMonth = analyticsRepository.countActiveUsersSince(monthStart);

        // Ensure consistency (a user active today is also active this week/month)
        activeUsersThisWeek = Math.max(activeUsersThisWeek, activeUsersToday);
        activeUsersThisMonth = Math.max(activeUsersThisMonth, activeUsersThisWeek);

        return OverviewStatsResponse.builder()
                .totalUsers(totalUsers)
                .totalProperties(totalProperties)
                .totalPendingProperties(totalPendingProperties)
                .totalApprovedProperties(totalApprovedProperties)
                .totalRejectedProperties(totalRejectedProperties)
                .totalSoldProperties(totalSoldProperties)
                .totalChats(totalChats)
                .totalMessages(totalMessages)
                .totalFavorites(totalFavorites)
                .totalNotifications(totalNotifications)
                .totalReports(totalReports)
                .totalBoostPurchases(totalBoostPurchases)
                .totalRevenue(totalRevenue)
                .activeUsersToday(activeUsersToday)
                .activeUsersThisWeek(activeUsersThisWeek)
                .activeUsersThisMonth(activeUsersThisMonth)
                .build();
    }

    @Override
    public UserGrowthResponse getUserGrowthStats() {
        List<Instant> userRegs = analyticsRepository.getUserRegistrationTimestamps();
        return UserGrowthResponse.builder()
                .dailyRegistrations(groupDaily(userRegs))
                .weeklyRegistrations(groupWeekly(userRegs))
                .monthlyRegistrations(groupMonthly(userRegs))
                .build();
    }

    @Override
    public PropertyAnalyticsResponse getPropertyStats() {
        List<Object[]> typeCounts = analyticsRepository.getPropertyCountByPropertyType();
        Map<String, Long> propertiesByType = new TreeMap<>();
        for (Object[] row : typeCounts) {
            if (row[0] != null) {
                propertiesByType.put(row[0].toString(), (Long) row[1]);
            }
        }

        List<Object[]> statusCounts = analyticsRepository.getPropertyCountByStatus();
        Map<String, Long> propertiesByStatus = new TreeMap<>();
        for (Object[] row : statusCounts) {
            if (row[0] != null) {
                propertiesByStatus.put(row[0].toString(), (Long) row[1]);
            }
        }

        List<Object[]> listingCounts = analyticsRepository.getPropertyCountByListingType();
        Map<String, Long> propertiesByListingType = new TreeMap<>();
        for (Object[] row : listingCounts) {
            if (row[0] != null) {
                propertiesByListingType.put(row[0].toString(), (Long) row[1]);
            }
        }

        List<Instant> creations = analyticsRepository.getPropertyCreationTimestamps();
        Map<String, Long> propertiesCreatedOverTime = groupDaily(creations);

        List<String> addresses = analyticsRepository.getPropertyAddresses();
        Map<String, Long> propertiesByCity = new TreeMap<>();
        for (String addr : addresses) {
            String city = extractCity(addr);
            propertiesByCity.put(city, propertiesByCity.getOrDefault(city, 0L) + 1);
        }

        return PropertyAnalyticsResponse.builder()
                .propertiesByType(propertiesByType)
                .propertiesByStatus(propertiesByStatus)
                .propertiesByCity(propertiesByCity)
                .propertiesByListingType(propertiesByListingType)
                .propertiesCreatedOverTime(propertiesCreatedOverTime)
                .build();
    }

    @Override
    public RevenueAnalyticsResponse getRevenueStats() {
        BigDecimal totalRevenue = analyticsRepository.sumBoostRevenue();

        List<Object[]> purchases = analyticsRepository.getBoostRevenueByMonth();
        Map<String, BigDecimal> monthlyRevenue = new TreeMap<>();
        for (Object[] row : purchases) {
            Instant createdAt = (Instant) row[0];
            BigDecimal amount = (BigDecimal) row[1];
            if (createdAt != null && amount != null) {
                String month = createdAt.atZone(ZoneOffset.UTC).toLocalDate().toString().substring(0, 7); // yyyy-MM
                monthlyRevenue.put(month, monthlyRevenue.getOrDefault(month, BigDecimal.ZERO).add(amount));
            }
        }

        // Mom growth calculation
        String thisMonthKey = YearMonth.now(ZoneOffset.UTC).toString();
        String lastMonthKey = YearMonth.now(ZoneOffset.UTC).minusMonths(1).toString();
        BigDecimal thisMonthRevenue = monthlyRevenue.getOrDefault(thisMonthKey, BigDecimal.ZERO);
        BigDecimal lastMonthRevenue = monthlyRevenue.getOrDefault(lastMonthKey, BigDecimal.ZERO);

        double revenueGrowth = 0.0;
        if (lastMonthRevenue.compareTo(BigDecimal.ZERO) > 0) {
            revenueGrowth = thisMonthRevenue.subtract(lastMonthRevenue)
                    .divide(lastMonthRevenue, 4, java.math.RoundingMode.HALF_UP)
                    .doubleValue() * 100.0;
        } else if (thisMonthRevenue.compareTo(BigDecimal.ZERO) > 0) {
            revenueGrowth = 100.0; // Starting from zero represents a 100% positive growth
        }

        List<Object[]> rawSellers = analyticsRepository.getTopSellers();
        List<SellerRevenueDto> topSellers = new ArrayList<>();
        for (Object[] row : rawSellers) {
            User seller = (User) row[0];
            BigDecimal rev = (BigDecimal) row[1];
            if (seller != null) {
                topSellers.add(SellerRevenueDto.builder()
                        .sellerId(seller.getId())
                        .sellerName(seller.getName() != null ? seller.getName() : seller.getEmail())
                        .sellerEmail(seller.getEmail())
                        .revenue(rev != null ? rev : BigDecimal.ZERO)
                        .build());
            }
        }

        return RevenueAnalyticsResponse.builder()
                .boostPurchaseRevenue(totalRevenue)
                .monthlyRevenue(monthlyRevenue)
                .revenueGrowth(revenueGrowth)
                .topSellers(topSellers)
                .build();
    }

    @Override
    public ChatAnalyticsResponse getChatStats() {
        long totalConversations = analyticsRepository.countConversations();
        long activeChats = analyticsRepository.countConversationsWithMessages();

        List<Instant> msgTimes = analyticsRepository.getMessageCreationTimestamps();
        Map<String, Long> messagesPerDay = groupDaily(msgTimes);

        List<Object[]> rawUsers = analyticsRepository.getMostActiveUsers();
        List<UserActivityDto> mostActiveUsers = new ArrayList<>();
        for (Object[] row : rawUsers) {
            User sender = (User) row[0];
            Long count = (Long) row[1];
            if (sender != null) {
                mostActiveUsers.add(UserActivityDto.builder()
                        .userId(sender.getId())
                        .userName(sender.getName() != null ? sender.getName() : sender.getEmail())
                        .userEmail(sender.getEmail())
                        .messageCount(count != null ? count : 0L)
                        .build());
            }
        }

        return ChatAnalyticsResponse.builder()
                .totalConversations(totalConversations)
                .activeChats(activeChats)
                .messagesPerDay(messagesPerDay)
                .mostActiveUsers(mostActiveUsers)
                .build();
    }

    @Override
    public EngagementAnalyticsResponse getEngagementStats() {
        List<Instant> favTimes = analyticsRepository.getFavoriteCreationTimestamps();
        Map<String, Long> favoritesTrends = groupDaily(favTimes);

        List<Instant> notTimes = analyticsRepository.getNotificationCreationTimestamps();
        Map<String, Long> notificationsTrends = groupDaily(notTimes);

        List<Object[]> rawViewed = analyticsRepository.getMostViewedProperties();
        List<PropertyPerformanceDto> mostViewed = new ArrayList<>();
        for (Object[] row : rawViewed) {
            Property prop = (Property) row[0];
            Long count = (Long) row[1];
            if (prop != null) {
                mostViewed.add(PropertyPerformanceDto.builder()
                        .propertyId(prop.getId())
                        .propertyTitle(prop.getTitle())
                        .count(count != null ? count : 0L)
                        .build());
            }
        }

        List<Object[]> rawFavorited = analyticsRepository.getMostFavoritedProperties();
        List<PropertyPerformanceDto> mostFavorited = new ArrayList<>();
        for (Object[] row : rawFavorited) {
            Property prop = (Property) row[0];
            Long count = (Long) row[1];
            if (prop != null) {
                mostFavorited.add(PropertyPerformanceDto.builder()
                        .propertyId(prop.getId())
                        .propertyTitle(prop.getTitle())
                        .count(count != null ? count : 0L)
                        .build());
            }
        }

        return EngagementAnalyticsResponse.builder()
                .favoritesTrends(favoritesTrends)
                .notificationsTrends(notificationsTrends)
                .mostViewedProperties(mostViewed)
                .mostFavoritedProperties(mostFavorited)
                .build();
    }

    @Override
    public ModerationAnalyticsResponse getModerationStats() {
        List<Instant> appTimes = analyticsRepository.getPropertyApprovalTimestamps();
        Map<String, Long> approvalsOverTime = groupDaily(appTimes);

        long approvals = analyticsRepository.countApprovals();
        long rejections = analyticsRepository.countRejections();
        double rejectionRate = 0.0;
        long totalActions = approvals + rejections;
        if (totalActions > 0) {
            rejectionRate = ((double) rejections / totalActions) * 100.0;
        }

        List<Object[]> rawMods = analyticsRepository.getModerationActivity();
        List<AdminActivityDto> moderationActivity = new ArrayList<>();
        for (Object[] row : rawMods) {
            User admin = (User) row[0];
            Long count = (Long) row[1];
            if (admin != null) {
                moderationActivity.add(AdminActivityDto.builder()
                        .adminId(admin.getId())
                        .adminName(admin.getName() != null ? admin.getName() : admin.getEmail())
                        .adminEmail(admin.getEmail())
                        .actionCount(count != null ? count : 0L)
                        .build());
            }
        }

        List<LogActivity> rawLogs = analyticsRepository.getRecentModerationLogs(20);
        List<AuditLogItem> adminActivityLogs = new ArrayList<>();
        for (LogActivity la : rawLogs) {
            adminActivityLogs.add(AuditLogItem.builder()
                    .id(la.getId())
                    .userId(la.getUser() != null ? la.getUser().getId() : null)
                    .userName(la.getUser() != null ? (la.getUser().getName() != null ? la.getUser().getName() : la.getUser().getEmail()) : "System")
                    .userEmail(la.getUser() != null ? la.getUser().getEmail() : "system@homely.com")
                    .activityType(la.getActivityType() != null ? la.getActivityType().name() : "UNKNOWN")
                    .entityType(la.getEntityType() != null ? la.getEntityType().name() : "UNKNOWN")
                    .entityId(la.getEntityId() != null ? la.getEntityId().toString() : "")
                    .description(la.getDescription() != null ? la.getDescription() : "")
                    .changes(la.getChanges() != null ? la.getChanges() : "")
                    .createdAt(la.getCreatedAt())
                    .build());
        }

        return ModerationAnalyticsResponse.builder()
                .approvalsOverTime(approvalsOverTime)
                .rejectionRate(rejectionRate)
                .moderationActivity(moderationActivity)
                .adminActivityLogs(adminActivityLogs)
                .build();
    }

    // Helper method to extract city from property address string
    private String extractCity(String address) {
        if (address == null || address.trim().isEmpty()) {
            return "Unknown";
        }
        String[] parts = address.split(",");
        if (parts.length > 1) {
            // Check second-to-last or last part of address format (e.g., "Street, City, Zip/Country" or "City, Country")
            String cityPart = parts[parts.length - 2].trim();
            if (cityPart.isEmpty() || cityPart.matches(".*\\d+.*")) {
                // If it contains numbers or is empty, use the first segment or the last segment minus numbers
                cityPart = parts[0].trim();
            }
            return cityPart;
        }
        return address.trim();
    }

    // Date grouping helpers
    private Map<String, Long> groupDaily(List<Instant> instants) {
        Map<String, Long> map = new TreeMap<>();
        for (Instant inst : instants) {
            if (inst == null) continue;
            String dateKey = inst.atZone(ZoneOffset.UTC).toLocalDate().toString();
            map.put(dateKey, map.getOrDefault(dateKey, 0L) + 1);
        }
        return map;
    }

    private Map<String, Long> groupWeekly(List<Instant> instants) {
        Map<String, Long> map = new TreeMap<>();
        for (Instant inst : instants) {
            if (inst == null) continue;
            LocalDate date = inst.atZone(ZoneOffset.UTC).toLocalDate();
            LocalDate startOfWeek = date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            String weekKey = startOfWeek.toString();
            map.put(weekKey, map.getOrDefault(weekKey, 0L) + 1);
        }
        return map;
    }

    private Map<String, Long> groupMonthly(List<Instant> instants) {
        Map<String, Long> map = new TreeMap<>();
        for (Instant inst : instants) {
            if (inst == null) continue;
            LocalDate date = inst.atZone(ZoneOffset.UTC).toLocalDate();
            YearMonth ym = YearMonth.from(date);
            String monthKey = ym.toString();
            map.put(monthKey, map.getOrDefault(monthKey, 0L) + 1);
        }
        return map;
    }
}
