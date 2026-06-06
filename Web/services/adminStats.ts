import { api } from "@/lib/api";

export interface OverviewStats {
  totalUsers: number;
  totalProperties: number;
  totalPendingProperties: number;
  totalApprovedProperties: number;
  totalRejectedProperties: number;
  totalSoldProperties: number;
  totalChats: number;
  totalMessages: number;
  totalFavorites: number;
  totalNotifications: number;
  totalReports: number;
  totalBoostPurchases: number;
  totalRevenue: number;
  activeUsersToday: number;
  activeUsersThisWeek: number;
  activeUsersThisMonth: number;
}

export interface UserGrowthStats {
  dailyRegistrations: Record<string, number>;
  weeklyRegistrations: Record<string, number>;
  monthlyRegistrations: Record<string, number>;
}

export interface PropertyStats {
  propertiesByType: Record<string, number>;
  propertiesByStatus: Record<string, number>;
  propertiesByCity: Record<string, number>;
  propertiesByListingType: Record<string, number>;
  propertiesCreatedOverTime: Record<string, number>;
}

export interface SellerRevenue {
  sellerId: string;
  sellerName: string;
  sellerEmail: string;
  revenue: number;
}

export interface RevenueStats {
  boostPurchaseRevenue: number;
  monthlyRevenue: Record<string, number>;
  revenueGrowth: number;
  topSellers: SellerRevenue[];
}

export interface UserActivity {
  userId: string;
  userName: string;
  userEmail: string;
  messageCount: number;
}

export interface ChatAnalytics {
  totalConversations: number;
  messagesPerDay: Record<string, number>;
  activeChats: number;
  mostActiveUsers: UserActivity[];
}

export interface MediaPropertyCount {
  propertyId: string;
  propertyTitle: string;
  mediaCount: number;
}

export interface MediaStats {
  totalMediaFiles: number;
  totalImages: number;
  totalVideos: number;
  averageMediaPerProperty: number;
  mediaByType: Record<string, number>;
  mediaUploadedOverTime: Record<string, number>;
  topPropertiesByMediaCount: MediaPropertyCount[];
  propertiesWithNoMedia: number;
}

export interface PropertyEngagement {
  propertyId: string;
  propertyTitle: string;
  count: number;
}

export interface EngagementStats {
  favoritesTrends: Record<string, number>;
  notificationsTrends: Record<string, number>;
  mostViewedProperties: PropertyEngagement[];
  mostFavoritedProperties: PropertyEngagement[];
}

export interface AdminActivity {
  adminId: string;
  adminName: string;
  adminEmail: string;
  actionCount: number;
}

export interface AuditLogItem {
  id: string;
  userId: string;
  userName: string;
  userEmail: string;
  activityType: string;
  entityType: string;
  entityId: string;
  description: string;
  changes: string;
  createdAt: string;
}

export interface ModerationAnalytics {
  approvalsOverTime: Record<string, number>;
  rejectionRate: number;
  moderationActivity: AdminActivity[];
  adminActivityLogs: AuditLogItem[];
}

// --- API CENTRALIZED CALLS ---

export const adminStatsService = {
  getOverview: async (): Promise<OverviewStats> => {
    const res = await api.get<OverviewStats>("/admin/stats/overview");
    return res.data;
  },

  getUserGrowth: async (): Promise<UserGrowthStats> => {
    const res = await api.get<UserGrowthStats>("/admin/stats/users-growth");
    return res.data;
  },

  getProperties: async (): Promise<PropertyStats> => {
    const res = await api.get<PropertyStats>("/admin/stats/properties");
    return res.data;
  },

  getRevenue: async (): Promise<RevenueStats> => {
    const res = await api.get<RevenueStats>("/admin/stats/revenue");
    return res.data;
  },

  getChats: async (): Promise<ChatAnalytics> => {
    const res = await api.get<ChatAnalytics>("/admin/stats/chats");
    return res.data;
  },

  getEngagement: async (): Promise<EngagementStats> => {
    const res = await api.get<EngagementStats>("/admin/stats/engagement");
    return res.data;
  },

  getModeration: async (): Promise<ModerationAnalytics> => {
    const res = await api.get<ModerationAnalytics>("/admin/stats/moderation");
    return res.data;
  },

  getMedia: async (): Promise<MediaStats> => {
    const res = await api.get<MediaStats>("/admin/stats/media");
    return res.data;
  },
};
