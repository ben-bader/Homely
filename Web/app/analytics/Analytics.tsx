"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
import { useLocale } from "next-intl";
import {
  TrendingUp,
  TrendingDown,
  Users,
  Home,
  MessageSquare,
  Heart,
  AlertTriangle,
  Zap,
  DollarSign,
  Activity,
  Printer,
  RefreshCw,
  FileSpreadsheet,
  Flag,
  ShieldCheck,
  Building2,
  Image,
  Video,
  FileImage,
  LayoutGrid,
} from "lucide-react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
} from "recharts";
import {
  adminStatsService,
  OverviewStats,
  UserGrowthStats,
  PropertyStats,
  RevenueStats,
  ChatAnalytics,
  EngagementStats,
  ModerationAnalytics,
  MediaStats,
} from "@/services/adminStats";

type Language = "en" | "fr";

const dict = {
  en: {
    liveAnalytics: "System Live Analytics",
    title: "Centralized Platform Stats",
    subtitle: "Monitor real-time system metrics.",
    refresh: "Refresh",
    exportCsv: "Export CSV",
    printReport: "Print Report",
    last7Days: "Last 7 Days",
    last30Days: "Last 30 Days",
    allTime: "All Time",
    tabs: {
      overview: "Overview",
      users: "Users",
      properties: "Properties",
      revenue: "Revenue",
      chats: "Chats & Engagement",
      moderation: "Moderation",
      media: "Media",
    },
    overviewTab: {
      platformUsers: "Platform Users",
      activeToday: "{count} active on the platform today",
      listedProperties: "Listed Properties",
      approvedActive: "{count} Approved / Active",
      premiumBoostSales: "Premium Boost Sales",
      promoAdsDesc: "Total promotional items approved for highlight",
      platformRevenue: "Platform Revenue",
      generatedFrom: "From {count} premium ads",
      propMod: "Property Moderation",
      propPendingDesc: "Properties currently pending admin validation.",
      reportsFlags: "Reports & Flags",
      reportsFlagsDesc: "Open tickets regarding bad listings/behavior.",
      convOpened: "Conversations Opened",
      convDesc: "Generating {count} message exchanges.",
      quickActivity: "Quick Activity Graph",
      dailyTrends: "Daily platform engagement trends.",
      registrationsName: "New Registrations",
      systemStatus: "System Status",
      statusDesc: "Platform operational health.",
      apiConn: "API Connection",
      dbSync: "Database Sync",
      boostEngine: "Boost Engine",
      modQueue: "Moderation Queue",
      operational: "Operational",
      optimized: "Optimized",
      active: "Active",
      pendingCount: "{count} Pending",
      noOverviewStats: "No overview stats found.",
    },
    usersTab: {
      newUsers: "New User Registrations",
      userCreations: "Visualizing account creations over time.",
      growthChartName: "User Registrations",
      activeShare: "Active User Share",
      activeShareDesc: "Daily vs Weekly vs Monthly active users.",
      today: "Today",
      week: "Week",
      month: "Month",
      inactive: "Inactive",
      totalRegistered: "Total Registered",
      dailyActiveUsers: "Daily Active Users",
      loggedInToday: "Users who logged in or acted today.",
      weeklyActiveUsers: "Weekly Active Users",
      activeThisWeek: "Unique users active in the last 7 days.",
      monthlyActiveUsers: "Monthly Active Users",
      activeThisMonth: "Unique users active in the last 30 days.",
      noStats: "No user statistics found.",
    },
    propertiesTab: {
      byType: "Properties by Type",
      byTypeDesc: "Listing distribution among property categories.",
      byStatus: "Properties by Status",
      byStatusDesc: "Ratios of active, suspended, and draft properties.",
      overTime: "Listings Over Time",
      overTimeDesc: "Daily creations of property ads.",
      topCities: "Top Cities",
      topCitiesDesc: "Listings distribution by geographical city.",
      colCity: "City",
      colListings: "Listings",
      noCities: "No city listings found",
      noAnalytics: "No property analytics found.",
      chartLabel: "New Listings",
      totalListings: "Total Listings",
      approvedListings: "Approved Listings",
      approvedDesc: "Active and approved property listings.",
      pendingReview: "Pending Review",
      pendingDesc: "Awaiting administrative validation.",
      rejectedListings: "Rejected Listings",
      rejectedDesc: "Listings removed or denied by moderators.",
    },
    revenueTab: {
      totalRevenue: "Total Boost Ad Revenue",
      growthMoM: "Revenue Growth MoM",
      growthDesc: "Monthly growth of promotional sales.",
      monetizedSellers: "Monetized Sellers",
      purchasedSpots: "Sellers who purchased premium ad spots.",
      monthlyEarnings: "Monthly Earnings Trend",
      monthlyEarningsDesc: "Aggregated boost purchase revenues by month.",
      earningsChartName: "Revenue ($)",
      premiumSellers: "Premium Sellers",
      topSellersDesc: "Top revenue contributing agents and agencies.",
      colAgent: "Agent",
      colRevenue: "Revenue",
      noTransactions: "No revenue transactions recorded",
      noRecords: "No financial records found.",
    },
    chatsTab: {
      messagesAct: "Messages Activity",
      frequencyDesc: "Frequency of chat messages sent over time.",
      messagesChartName: "Messages Sent",
      favsAction: "Favorites Action",
      favsDesc: "Daily addition of listings to users' favorites.",
      favsChartName: "New Favorites",
      mostViewed: "Most Viewed Properties",
      mostViewedDesc: "Property listings with maximum viewer traffic.",
      mostFavorited: "Most Favorited Properties",
      mostFavoritedDesc: "Highly desired properties added to user wishlists.",
      colTitle: "Property Title",
      colViews: "Total Views",
      colFavorites: "Favorites Count",
      noViews: "No view traffic recorded",
      noFavorites: "No wishlist records found",
      noEngagement: "No engagement stats found.",
      totalChats: "Total Conversations",
      totalMessages: "Total Messages",
      totalMessagesDesc: "All messages exchanged across all conversations.",
      totalFavorites: "Total Favorites",
      totalFavoritesDesc: "All listing saves across all user accounts.",
      convDesc: "Generating {count} message exchanges.",
    },
    moderationTab: {
      approvalsTimeline: "Approvals Timeline",
      approvalsDesc: "Listed properties approved by administrative moderators over time.",
      approvalsChartName: "Approvals",
      rejectionRatio: "Rejection Ratio",
      rejectionDesc: "Percentage of listing rejections relative to total actions.",
      rejectionLabel: "Platform Rejection Ratio",
      approvalRate: "Approval Rate",
      calculatedFrom: "Calculated dynamically from total administrative Approve and Reject operations.",
      modActivity: "Mod Activity",
      activeModsDesc: "Most active administrative moderators.",
      colMod: "Administrator",
      colActions: "Actions",
      noModActivity: "No moderator activity logged",
      adminLogs: "Administrative Logs",
      recentLogsDesc: "Recent audit logs of administrative moderations.",
      colTime: "Time",
      colAdmin: "Admin",
      colOperation: "Operation",
      colDetails: "Details",
      noAuditLogs: "No audit logs recorded",
      noRecords: "No moderation records found.",
      totalApprovals: "Total Approvals",
      totalApprovalsDesc: "All-time approved property listings.",
      totalRejections: "Total Rejections",
      totalRejectionsDesc: "All-time rejected property listings.",
      approvalRateLabel: "Approval Rate",
      activeAdmins: "Active Moderators",
      activeAdminsDesc: "Admins who have performed at least one action.",
    },
    mediaTab: {
      totalMedia: "Total Media Files",
      totalMediaDesc: "All images and videos uploaded to the platform.",
      totalImages: "Total Images",
      totalImagesDesc: "All image files uploaded across all properties.",
      totalVideos: "Total Videos",
      totalVideosDesc: "All video files uploaded across all properties.",
      avgPerProperty: "Avg. Media / Property",
      avgPerPropertyDesc: "Average number of media files per listed property.",
      noMediaProperties: "Properties Without Media",
      noMediaPropertiesDesc: "Properties that have no images or videos attached.",
      uploadTrend: "Media Upload Trend",
      uploadTrendDesc: "Daily media file uploads over time.",
      uploadChartName: "Uploads",
      byType: "Media Breakdown by Type",
      byTypeDesc: "Distribution of media files by type.",
      topProperties: "Top Properties by Media",
      topPropertiesDesc: "Properties with the highest number of uploaded files.",
      colProperty: "Property",
      colCount: "Files",
      noTopProperties: "No media records found.",
      noRecords: "No media statistics found.",
    },
    errorTitle: "Analytics Loading Failed",
    retryBtn: "Retry Loading",
  },
  fr: {
    liveAnalytics: "Analyses Système en Direct",
    title: "Statistiques Centralisées",
    subtitle: "Suivez en temps réel les indicateurs système.",
    refresh: "Rafraîchir",
    exportCsv: "Exporter CSV",
    printReport: "Imprimer Rapport",
    last7Days: "7 Derniers Jours",
    last30Days: "30 Derniers Jours",
    allTime: "Depuis le début",
    tabs: {
      overview: "Vue d'ensemble",
      users: "Utilisateurs",
      properties: "Propriétés",
      revenue: "Revenus",
      chats: "Chats & Engagement",
      moderation: "Modération",
      media: "Médias",
    },
    overviewTab: {
      platformUsers: "Utilisateurs",
      activeToday: "{count} actifs sur la plateforme aujourd'hui",
      listedProperties: "Propriétés Répertoriées",
      approvedActive: "{count} Approuvées / Actives",
      premiumBoostSales: "Ventes de Boosts Premium",
      promoAdsDesc: "Total des annonces promotionnelles approuvées pour mise en avant",
      platformRevenue: "Revenus de la Plateforme",
      generatedFrom: "A partir de {count} annonces premium",
      propMod: "Modération de Propriétés",
      propPendingDesc: "Propriétés en attente de validation par les administrateurs.",
      reportsFlags: "Signalements & Plaintes",
      reportsFlagsDesc: "Tickets ouverts concernant de mauvaises annonces ou comportements.",
      convOpened: "Conversations Ouvertes",
      convDesc: "Générant {count} échanges de messages.",
      quickActivity: "Activité Quotidienne",
      dailyTrends: "Tendances quotidiennes de l'engagement sur la plateforme.",
      registrationsName: "Nouvelles Inscriptions",
      systemStatus: "Statut du Système",
      statusDesc: "Santé opérationnelle de la plateforme.",
      apiConn: "Connexion API",
      dbSync: "Sync Base de Données",
      boostEngine: "Moteur de Boosts",
      modQueue: "File de Modération",
      operational: "Opérationnel",
      optimized: "Optimisé",
      active: "Actif",
      pendingCount: "{count} en attente",
      noOverviewStats: "Aucune statistique générale trouvée.",
    },
    usersTab: {
      newUsers: "Nouvelles Inscriptions",
      userCreations: "Visualisation des créations de comptes au fil du temps.",
      growthChartName: "Inscriptions d'Utilisateurs",
      activeShare: "Part des Utilisateurs Actifs",
      activeShareDesc: "Utilisateurs actifs quotidiens vs hebdomadaires vs mensuels.",
      today: "Aujourd'hui",
      week: "Semaine",
      month: "Mois",
      inactive: "Inactif",
      totalRegistered: "Total Inscrits",
      dailyActiveUsers: "Actifs du Jour",
      loggedInToday: "Utilisateurs connectés ou actifs aujourd'hui.",
      weeklyActiveUsers: "Actifs Hebdo",
      activeThisWeek: "Utilisateurs uniques actifs ces 7 derniers jours.",
      monthlyActiveUsers: "Actifs Mensuels",
      activeThisMonth: "Utilisateurs uniques actifs ces 30 derniers jours.",
      noStats: "Aucune statistique utilisateur trouvée.",
    },
    propertiesTab: {
      byType: "Propriétés par Type",
      byTypeDesc: "Distribution des annonces par catégorie de propriété.",
      byStatus: "Propriétés par Statut",
      byStatusDesc: "Ratios de propriétés actives, suspendues et brouillons.",
      overTime: "Annonces au Fil du Temps",
      overTimeDesc: "Créations quotidiennes d'annonces de propriétés.",
      topCities: "Top Villes",
      topCitiesDesc: "Distribution des annonces par ville géographique.",
      colCity: "Ville",
      colListings: "Annonces",
      noCities: "Aucune annonce trouvée par ville",
      noAnalytics: "Aucune analyse de propriété trouvée.",
      chartLabel: "Nouvelles Annonces",
      totalListings: "Total Annonces",
      approvedListings: "Annonces Approuvées",
      approvedDesc: "Annonces actives et approuvées.",
      pendingReview: "En Attente",
      pendingDesc: "En attente de validation administrative.",
      rejectedListings: "Annonces Rejetées",
      rejectedDesc: "Annonces supprimées ou refusées par les modérateurs.",
    },
    revenueTab: {
      totalRevenue: "Revenus Publicitaires Totaux",
      growthMoM: "Revenus MoM",
      growthDesc: "Croissance des ventes promotionnelles d'un mois sur l'autre.",
      monetizedSellers: "Vendeurs Monétisés",
      purchasedSpots: "Vendeurs ayant acheté des espaces publicitaires premium.",
      monthlyEarnings: "Tendance des Gains Mensuels",
      monthlyEarningsDesc: "Revenus cumulés des achats de boosts par mois.",
      earningsChartName: "Revenus ($)",
      premiumSellers: "Vendeurs Premium",
      topSellersDesc: "Principaux agents et agences contributeurs aux revenus.",
      colAgent: "Agent",
      colRevenue: "Revenus",
      noTransactions: "Aucune transaction enregistrée",
      noRecords: "Aucun enregistrement financier trouvé.",
    },
    chatsTab: {
      messagesAct: "Activité des Messages",
      frequencyDesc: "Fréquence des messages de chat envoyés au fil du temps.",
      messagesChartName: "Messages Envoyés",
      favsAction: "Favoris Ajoutés",
      favsDesc: "Ajouts quotidiens d'annonces aux favoris des utilisateurs.",
      favsChartName: "Nouveaux Favoris",
      mostViewed: "Propriétés les plus consultées",
      mostViewedDesc: "Annonces de propriétés avec le plus de trafic de visiteurs.",
      mostFavorited: "Propriétés les plus favorites",
      mostFavoritedDesc: "Propriétés hautement désirées ajoutées aux listes d'envies.",
      colTitle: "Titre de la Propriété",
      colViews: "Total Vues",
      colFavorites: "Nombre de Favoris",
      noViews: "Aucune vue enregistrée",
      noFavorites: "Aucun favori enregistré",
      noEngagement: "Aucune statistique d'engagement trouvée.",
      totalChats: "Conversations Totales",
      totalMessages: "Messages Totaux",
      totalMessagesDesc: "Tous les messages échangés dans toutes les conversations.",
      totalFavorites: "Favoris Totaux",
      totalFavoritesDesc: "Toutes les sauvegardes d'annonces par les utilisateurs.",
      convDesc: "Générant {count} échanges de messages.",
    },
    moderationTab: {
      approvalsTimeline: "Chronologie des Approbations",
      approvalsDesc: "Propriétés approuvées par les modérateurs administratifs au fil du temps.",
      approvalsChartName: "Approbations",
      rejectionRatio: "Taux de Rejet",
      rejectionDesc: "Pourcentage de rejets d'annonces par rapport au total des actions.",
      rejectionLabel: "Taux de Rejet de la Plateforme",
      approvalRate: "Taux d'Approbation",
      calculatedFrom: "Calculé dynamiquement à partir des opérations d'approbation et de rejet des administrateurs.",
      modActivity: "Activité des Modérateurs",
      activeModsDesc: "Modérateurs administratifs les plus actifs.",
      colMod: "Modérateur",
      colActions: "Actions",
      noModActivity: "Aucune activité de modérateur enregistrée",
      adminLogs: "Journaux d'Audit Admin",
      recentLogsDesc: "Journaux d'audit récents des modérations administratives.",
      colTime: "Heure",
      colAdmin: "Admin",
      colOperation: "Opération",
      colDetails: "Détails",
      noAuditLogs: "Aucun journal d'audit enregistré",
      noRecords: "Aucun enregistrement de modération trouvé.",
      totalApprovals: "Total Approbations",
      totalApprovalsDesc: "Annonces approuvées depuis le début.",
      totalRejections: "Total Rejets",
      totalRejectionsDesc: "Annonces rejetées depuis le début.",
      approvalRateLabel: "Taux d'Approbation",
      activeAdmins: "Modérateurs Actifs",
      activeAdminsDesc: "Admins ayant effectué au moins une action.",
    },
    mediaTab: {
      totalMedia: "Total Fichiers Médias",
      totalMediaDesc: "Toutes les images et vidéos téléchargées sur la plateforme.",
      totalImages: "Total Images",
      totalImagesDesc: "Toutes les images téléchargées pour toutes les propriétés.",
      totalVideos: "Total Vidéos",
      totalVideosDesc: "Toutes les vidéos téléchargées pour toutes les propriétés.",
      avgPerProperty: "Moy. Médias / Propriété",
      avgPerPropertyDesc: "Nombre moyen de fichiers médias par propriété.",
      noMediaProperties: "Propriétés Sans Médias",
      noMediaPropertiesDesc: "Propriétés sans images ni vidéos attachées.",
      uploadTrend: "Tendance des Téléchargements",
      uploadTrendDesc: "Téléchargements quotidiens de fichiers médias au fil du temps.",
      uploadChartName: "Téléchargements",
      byType: "Répartition par Type",
      byTypeDesc: "Distribution des fichiers médias par type.",
      topProperties: "Top Propriétés par Médias",
      topPropertiesDesc: "Propriétés avec le plus grand nombre de fichiers téléchargés.",
      colProperty: "Propriété",
      colCount: "Fichiers",
      noTopProperties: "Aucun enregistrement média trouvé.",
      noRecords: "Aucune statistique média trouvée.",
    },
    errorTitle: "Échec du Chargement des Analyses",
    retryBtn: "Réessayer le Chargement",
  },
};

// ─── Shared chart color palette ───────────────────────────────────────────────
const COLORS = ["#4f46e5", "#8b5cf6", "#10b981", "#f59e0b", "#ef4444", "#3b82f6", "#ec4899"];

// ─── Per-tab hero gradient + accent color ────────────────────────────────────
const HERO_STYLES = {
  overview: {
    gradient: "linear-gradient(135deg, #3730a3 0%, #4f46e5 60%, #6366f1 100%)",
    chartStroke: "#2e54ff",
    chartGradientId: "colorRegs",
  },
  users: {
    gradient: "linear-gradient(135deg, #064e3b 0%, #0f766e 55%, #14b8a6 100%)",
    chartStroke: "#0f766e",
    chartGradientId: "colorUsers",
  },
  properties: {
    gradient: "linear-gradient(135deg, #581c87 0%, #7e22ce 55%, #a855f7 100%)",
    chartStroke: "#7e22ce",
    chartGradientId: "colorProps",
  },
  revenue: {
    gradient: "linear-gradient(135deg, #022c22 0%, #065f46 50%, #059669 100%)",
    chartStroke: "#059669",
    chartGradientId: "colorRev",
  },
  chats: {
    gradient: "linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 55%, #3b82f6 100%)",
    chartStroke: "#1d4ed8",
    chartGradientId: "colorMsgs",
  },
  moderation: {
    gradient: "linear-gradient(135deg, #451a03 0%, #92400e 50%, #d97706 100%)",
    chartStroke: "#d97706",
    chartGradientId: "colorApps",
  },
  // Media: deep slate → cyan — storage, files, digital assets
  media: {
    gradient: "linear-gradient(135deg, #0f172a 0%, #0e7490 55%, #06b6d4 100%)",
    chartStroke: "#06b6d4",
    chartGradientId: "colorMedia",
  },
} as const;

type TabKey = keyof typeof HERO_STYLES;

// ─── Reusable hero card shell ────────────────────────────────────────────────
function HeroCard({ tab, children }: { tab: TabKey; children: React.ReactNode }) {
  return (
    <Card
      className="lg:col-span-2 lg:row-span-1 border-transparent"
      style={{ background: HERO_STYLES[tab].gradient }}
    >
      {children}
    </Card>
  );
}

// ─── White KPI card ──────────────────────────────────────────────────────────
function KpiCard({
  label,
  value,
  description,
  icon,
}: {
  label: string;
  value: React.ReactNode;
  description: string;
  icon: React.ReactNode;
}) {
  return (
    <Card className="bg-white border-transparent h-full flex flex-col">
      <CardHeader className="pb-3 flex-1">
        <div className="flex flex-col h-full justify-between items-start">
          <div className="flex justify-between items-center w-full">
            <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">
              {label}
            </CardDescription>
            {icon}
          </div>
          <div className="relative top-8">
            <CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">{value}</CardTitle>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <p className="text-xs text-muted-foreground">{description}</p>
      </CardContent>
    </Card>
  );
}

export default function Analytics() {
  const locale = useLocale();
  const lang = (locale === "fr" ? "fr" : "en") as Language;
  const t = dict[lang];
  const dateLocale = lang === "fr" ? "fr-FR" : "en-US";

  const [mounted, setMounted] = useState(false);
  const [overview, setOverview] = useState<OverviewStats | null>(null);
  const [userGrowth, setUserGrowth] = useState<UserGrowthStats | null>(null);
  const [properties, setProperties] = useState<PropertyStats | null>(null);
  const [revenue, setRevenue] = useState<RevenueStats | null>(null);
  const [chats, setChats] = useState<ChatAnalytics | null>(null);
  const [engagement, setEngagement] = useState<EngagementStats | null>(null);
  const [moderation, setModeration] = useState<ModerationAnalytics | null>(null);
  const [media, setMedia] = useState<MediaStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [timeRange, setTimeRange] = useState<"7d" | "30d" | "all">("30d");
  const [activeTab, setActiveTab] = useState("overview");
  const [isRefreshing, setIsRefreshing] = useState(false);

  useEffect(() => { setMounted(true); }, []);

  const fetchAllData = useCallback(async (isSilent = false) => {
    if (!isSilent) setLoading(true);
    setError(null);
    try {
      const [overviewRes, growthRes, propsRes, revRes, chatsRes, engRes, modRes, mediaRes] = await Promise.all([
        adminStatsService.getOverview(),
        adminStatsService.getUserGrowth(),
        adminStatsService.getProperties(),
        adminStatsService.getRevenue(),
        adminStatsService.getChats(),
        adminStatsService.getEngagement(),
        adminStatsService.getModeration(),
        adminStatsService.getMedia(),
      ]);
      setOverview(overviewRes);
      setUserGrowth(growthRes);
      setProperties(propsRes);
      setRevenue(revRes);
      setChats(chatsRes);
      setEngagement(engRes);
      setModeration(modRes);
      setMedia(mediaRes);
    } catch (err: any) {
      setError(err?.response?.data?.message || err?.message || (lang === "fr" ? "Échec du chargement." : "Failed to load analytics."));
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }, [lang]);

  useEffect(() => { fetchAllData(); }, [fetchAllData]);

  const handleManualRefresh = () => { setIsRefreshing(true); fetchAllData(); };

  const handleExportCSV = () => {
    let dataset: any[] = [];
    const filename = `homely_analytics_${activeTab}`;
    if (activeTab === "overview" && overview) {
      dataset = [
        { Metric: "Total Registered Users", Value: overview.totalUsers },
        { Metric: "Total Properties", Value: overview.totalProperties },
        { Metric: "Pending Properties", Value: overview.totalPendingProperties },
        { Metric: "Approved Properties", Value: overview.totalApprovedProperties },
        { Metric: "Rejected Properties", Value: overview.totalRejectedProperties },
        { Metric: "Conversations Opened", Value: overview.totalChats },
        { Metric: "Messages Sent", Value: overview.totalMessages },
        { Metric: "User Favorites Count", Value: overview.totalFavorites },
        { Metric: "Total Notifications Transmitted", Value: overview.totalNotifications },
        { Metric: "Reports Filed", Value: overview.totalReports },
        { Metric: "Total Boost Sales Count", Value: overview.totalBoostPurchases },
        { Metric: "Total Platform Revenue (USD)", Value: overview.totalRevenue },
        { Metric: "Daily Active Users", Value: overview.activeUsersToday },
        { Metric: "Weekly Active Users", Value: overview.activeUsersThisWeek },
        { Metric: "Monthly Active Users", Value: overview.activeUsersThisMonth },
      ];
    } else if (activeTab === "users" && userGrowth) {
      dataset = Object.entries(userGrowth.dailyRegistrations).map(([date, val]) => ({ Date: date, Registrations: val }));
    } else if (activeTab === "properties" && properties) {
      dataset = Object.entries(properties.propertiesByType).map(([type, val]) => ({ PropertyType: type, ListingCount: val }));
    } else if (activeTab === "revenue" && revenue) {
      dataset = revenue.topSellers.map((s, i) => ({ Rank: i + 1, SellerName: s.sellerName, SellerEmail: s.sellerEmail, TotalRevenueUSD: s.revenue }));
    } else if (activeTab === "chats" && chats) {
      dataset = chats.mostActiveUsers.map((u, i) => ({ Rank: i + 1, UserName: u.userName, UserEmail: u.userEmail, MessagesSent: u.messageCount }));
    } else if (activeTab === "moderation" && moderation) {
      dataset = moderation.adminActivityLogs.map((l) => ({ Time: new Date(l.createdAt).toLocaleString(dateLocale), AdminName: l.userName, Action: l.activityType, Entity: l.entityType, Description: l.description }));
    } else if (activeTab === "media" && media) {
      dataset = media.topPropertiesByMediaCount.map((p, i) => ({ Rank: i + 1, PropertyTitle: p.propertyTitle, MediaFiles: p.mediaCount }));
    }
    if (!dataset.length) { alert(lang === "fr" ? "Aucune donnée disponible." : "No data available for export."); return; }
    const headers = Object.keys(dataset[0]).join(",");
    const rows = dataset.map((obj) => Object.values(obj).map((val) => `"${String(val).replace(/"/g, '""')}"`).join(","));
    const csvContent = "data:text/csv;charset=utf-8," + [headers, ...rows].join("\n");
    const link = document.createElement("a");
    link.setAttribute("href", encodeURI(csvContent));
    link.setAttribute("download", `${filename}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handlePrintPDF = () => window.print();

  const filterTrends = <T extends number | string>(trendData: Record<string, T> | undefined): Array<{ date: string; value: number }> => {
    if (!trendData) return [];
    const entries = Object.entries(trendData).map(([date, val]) => ({ date, value: typeof val === "number" ? val : parseFloat(val.toString()) }));
    if (timeRange === "7d") return entries.slice(-7);
    if (timeRange === "30d") return entries.slice(-30);
    return entries;
  };

  const activeSellersCount = useMemo(() => (revenue ? revenue.topSellers.length : 0), [revenue]);
  const moderationDecisionStats = useMemo(() => {
    const approvals = overview?.totalApprovedProperties ?? 0;
    const rejections = overview?.totalRejectedProperties ?? 0;
    const total = approvals + rejections;

    return {
      approvals,
      rejections,
      approvalRate: total > 0 ? (approvals / total) * 100 : 0,
      rejectionRate: total > 0 ? (rejections / total) * 100 : 0,
    };
  }, [overview]);

  const tooltipStyle = {
    contentStyle: {
      background: "hsl(var(--background))",
      border: "1px solid hsl(var(--border))",
      borderRadius: "8px",
    },
  };

  const SkeletonGrid = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      {[...Array(6)].map((_, i) => (
        <Card key={i} className="bg-muted/15 border-muted/50">
          <CardHeader className="pb-2"><Skeleton className="h-4 w-28 mb-1" /><Skeleton className="h-8 w-20" /></CardHeader>
          <CardContent><Skeleton className="h-3 w-36" /></CardContent>
        </Card>
      ))}
    </div>
  );

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center p-8 min-h-[500px]">
        <div className="p-4 bg-destructive/10 text-destructive rounded-full mb-4">
          <AlertTriangle className="size-10" />
        </div>
        <h3 className="text-xl font-bold mb-2">{t.errorTitle}</h3>
        <p className="text-muted-foreground text-center max-w-md mb-6">{error}</p>
        <Button onClick={() => fetchAllData()} className="flex items-center gap-2">
          <RefreshCw className="size-4" /> {t.retryBtn}
        </Button>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-8 p-6 md:p-8 w-full max-w-[1400px] mx-auto print:p-0 print:max-w-full">

      {/* ── Header ── */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 print:hidden">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <Badge variant="secondary" className="bg-primary/10 text-indigo-700 hover:bg-primary/15 border-primary/20 font-medium gap-1.5 py-0.5 px-2.5">
              <span className="relative flex size-2">
                <span className="relative inline-flex rounded-full size-2 bg-primary" />
              </span>
              {t.liveAnalytics}
            </Badge>
          </div>
          <h1 className="text-3xl font-extrabold tracking-tight text-foreground">{t.title}</h1>
          <p className="text-muted-foreground text-sm leading-relaxed">{t.subtitle}</p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <Button variant="outline" size="sm" onClick={handleManualRefresh} disabled={isRefreshing || loading} className="gap-2 text-xs font-semibold h-8 rounded-full">
            <RefreshCw className={`size-3.5 ${isRefreshing ? "animate-spin" : ""}`} /> {t.refresh}
          </Button>
          <Button variant="outline" size="sm" onClick={handleExportCSV} disabled={loading} className="gap-2 text-xs font-semibold h-8 rounded-full">
            <FileSpreadsheet className="size-3.5 text-emerald-600" /> {t.exportCsv}
          </Button>
          <Button variant="outline" size="sm" onClick={handlePrintPDF} disabled={loading} className="gap-2 text-xs font-semibold h-8 rounded-full">
            <Printer className="size-3.5 text-primary" /> {t.printReport}
          </Button>
        </div>
      </div>

      {/* ── Date Range ── */}
      <div className="flex items-center gap-2 bg-white p-1 border shadow-[0_1px_2px_rgba(16,24,40,0.04),0_4px_12px_rgba(16,24,40,0.04)] rounded-full self-start print:hidden">
        {(["7d", "30d", "all"] as const).map((range) => (
          <Button key={range} variant={timeRange === range ? "secondary" : "ghost"} size="sm" className="text-xs py-1 h-7 font-medium px-3 rounded-full" onClick={() => setTimeRange(range)}>
            {range === "7d" ? t.last7Days : range === "30d" ? t.last30Days : t.allTime}
          </Button>
        ))}
      </div>

      {/* ── Tabs ── */}
      <Tabs defaultValue="overview" onValueChange={setActiveTab} className="w-full">
        <TabsList className="flex flex-1 items-center justify-center gap-1 bg-white p-1 shadow-[0_1px_2px_rgba(16,24,40,0.04),0_4px_12px_rgba(16,24,40,0.04)] border h-16 mb-8 print:hidden">
          {(["overview", "users", "properties", "revenue", "chats", "moderation", "media"] as const).map((tab) => (
            <TabsTrigger key={tab} value={tab} className="text-xs cursor-pointer data-[state=active]:text-white py-2 px-3 font-semibold data-[state=active]:bg-indigo-700">
              {t.tabs[tab]}
            </TabsTrigger>
          ))}
        </TabsList>

        {/* ══════════════════════════════════════════════════════════════════
            1. OVERVIEW
        ══════════════════════════════════════════════════════════════════ */}
        <TabsContent value="overview" className="flex flex-col gap-6">
          {loading ? <SkeletonGrid /> : overview ? (
            <>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[minmax(150px,200px)]">
                <HeroCard tab="overview">
                  <CardHeader className="-pb-6">
                    <div className="flex justify-between items-start">
                      <div className="space-y-1">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-white/90">{t.overviewTab.platformUsers}</CardDescription>
                        <CardTitle className="text-4xl font-extrabold tracking-tight text-white">{overview.totalUsers.toLocaleString()}</CardTitle>
                      </div>
                      <div className="bg-white/20 rounded-full w-8 h-8 flex items-center justify-center">
                        <Users className="size-4 text-white" />
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex items-center gap-2 text-sm">
                      <Activity className="size-4 text-green-400" />
                      <span className="text-gray-100">{t.overviewTab.activeToday.replace("{count}", String(overview.activeUsersToday))}</span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 pt-1 border-t border-white/20">
                      <div><p className="text-xs text-white/70">Weekly Active</p><p className="text-lg font-semibold text-white">{overview.activeUsersThisWeek.toLocaleString()}</p></div>
                      <div><p className="text-xs text-white/70">Monthly Active</p><p className="text-lg font-semibold text-white">{overview.activeUsersThisMonth.toLocaleString()}</p></div>
                    </div>
                  </CardContent>
                </HeroCard>

                <Card className="bg-white border-transparent h-full flex flex-col justify-between">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex flex-col h-full justify-between items-start">
                      <div className="flex justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">{t.overviewTab.listedProperties}</CardDescription>
                        <Home className="size-8 bg-violet-500 p-2 rounded-full text-white" />
                      </div>
                      <div className="relative top-8"><CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">{overview.totalProperties.toLocaleString()}</CardTitle></div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="flex items-center gap-2 text-xs">
                      <span className="inline-flex size-2 rounded-full bg-emerald-500" />
                      <span className="text-muted-foreground">{t.overviewTab.approvedActive.replace("{count}", String(overview.totalApprovedProperties))}</span>
                    </div>
                  </CardContent>
                </Card>

                <Card className="bg-white border-transparent h-full flex flex-col">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex flex-col h-full justify-between items-start">
                      <div className="flex flex-1 justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">{t.overviewTab.platformRevenue}</CardDescription>
                        <DollarSign className="size-8 p-2 bg-emerald-500 text-white rounded-full" />
                      </div>
                      <div className="relative top-8"><CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">${overview.totalRevenue.toLocaleString()}</CardTitle></div>
                    </div>
                  </CardHeader>
                  <CardContent><p className="text-xs text-muted-foreground">{t.overviewTab.generatedFrom.replace("{count}", String(overview.totalBoostPurchases))}</p></CardContent>
                </Card>

                <Card className="bg-white border-transparent h-full flex flex-col">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex flex-col h-full justify-between items-start">
                      <div className="flex flex-1 justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">{t.overviewTab.premiumBoostSales}</CardDescription>
                        <Zap className="size-8 p-2 rounded-full bg-amber-500 text-white" />
                      </div>
                      <div className="relative top-8"><CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">{overview.totalBoostPurchases.toLocaleString()}</CardTitle></div>
                    </div>
                  </CardHeader>
                  <CardContent><p className="text-xs text-muted-foreground font-medium text-foreground">{t.overviewTab.promoAdsDesc}</p></CardContent>
                </Card>

                <Card className="bg-white border-border h-full flex flex-col">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex flex-col h-full justify-between items-start">
                      <div className="flex flex-1 justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">{t.overviewTab.propMod}</CardDescription>
                        <AlertTriangle className="size-8 p-2 bg-amber-300 text-white rounded-full" />
                      </div>
                      <div className="relative top-8"><CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">{overview.totalPendingProperties}</CardTitle></div>
                    </div>
                  </CardHeader>
                  <CardContent><p className="text-xs text-muted-foreground">{t.overviewTab.propPendingDesc}</p></CardContent>
                </Card>

                <Card className="bg-card border-border h-full flex flex-col">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex flex-col h-full justify-between items-start">
                      <div className="flex flex-1 justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">{t.overviewTab.reportsFlags}</CardDescription>
                        <Flag className="size-8 p-2 bg-red-500 text-white rounded-full" />
                      </div>
                      <div className="relative top-8"><CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">{overview.totalReports}</CardTitle></div>
                    </div>
                  </CardHeader>
                  <CardContent><p className="text-xs text-muted-foreground">{t.overviewTab.reportsFlagsDesc}</p></CardContent>
                </Card>

                <Card className="bg-card border-border h-full flex flex-col">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex flex-col h-full justify-between items-start">
                      <div className="flex flex-1 justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">{t.overviewTab.convOpened}</CardDescription>
                        <MessageSquare className="size-8 p-2 bg-blue-500 text-white rounded-full" />
                      </div>
                      <div className="relative top-8"><CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">{overview.totalChats.toLocaleString()}</CardTitle></div>
                    </div>
                  </CardHeader>
                  <CardContent><p className="text-xs text-muted-foreground">{t.overviewTab.convDesc.replace("{count}", String(overview.totalMessages))}</p></CardContent>
                </Card>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.overviewTab.quickActivity}</CardTitle>
                    <CardDescription>{t.overviewTab.dailyTrends}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[320px] min-h-[300px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <AreaChart data={filterTrends(userGrowth?.dailyRegistrations)}>
                            <defs>
                              <linearGradient id="colorRegs" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#2e54ff" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="#2e54ff" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} tickMargin={8} />
                            <Tooltip {...tooltipStyle} />
                            <Area name={t.overviewTab.registrationsName} type="monotone" dataKey="value" stroke="#2e54ff" strokeWidth={2} fillOpacity={1} fill="url(#colorRegs)" />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[320px] rounded-xl" />}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.overviewTab.systemStatus}</CardTitle>
                    <CardDescription>{t.overviewTab.statusDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="flex flex-col gap-4">
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">{t.overviewTab.apiConn}</span>
                      <Badge className="bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20">{t.overviewTab.operational}</Badge>
                    </div>
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">{t.overviewTab.dbSync}</span>
                      <Badge className="bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20">{t.overviewTab.optimized}</Badge>
                    </div>
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">{t.overviewTab.boostEngine}</span>
                      <Badge className="bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20">{t.overviewTab.active}</Badge>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-muted-foreground">{t.overviewTab.modQueue}</span>
                      <Badge className={overview.totalPendingProperties > 5 ? "bg-amber-500/10 text-amber-500 border-amber-500/20" : "bg-emerald-500/10 text-emerald-500 border-emerald-500/20"}>
                        {t.overviewTab.pendingCount.replace("{count}", String(overview.totalPendingProperties))}
                      </Badge>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : <div className="text-center p-6 text-muted-foreground">{t.overviewTab.noOverviewStats}</div>}
        </TabsContent>

        {/* ══════════════════════════════════════════════════════════════════
            2. USERS
        ══════════════════════════════════════════════════════════════════ */}
        <TabsContent value="users" className="flex flex-col gap-6">
          {loading ? <SkeletonGrid /> : userGrowth && overview ? (
            <>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[minmax(150px,200px)]">
                <HeroCard tab="users">
                  <CardHeader className="-pb-6">
                    <div className="flex justify-between items-start">
                      <div className="space-y-1">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-white/90">{t.usersTab.totalRegistered}</CardDescription>
                        <CardTitle className="text-4xl font-extrabold tracking-tight text-white">{overview.totalUsers.toLocaleString()}</CardTitle>
                      </div>
                      <div className="bg-white/20 rounded-full w-8 h-8 flex items-center justify-center">
                        <Users className="size-4 text-white" />
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex items-center gap-2 text-sm">
                      <Activity className="size-4 text-emerald-300" />
                      <span className="text-white/90">{t.overviewTab.activeToday.replace("{count}", String(overview.activeUsersToday))}</span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 pt-1 border-t border-white/20">
                      <div><p className="text-xs text-white/70">{t.usersTab.week}</p><p className="text-lg font-semibold text-white">{overview.activeUsersThisWeek.toLocaleString()}</p></div>
                      <div><p className="text-xs text-white/70">{t.usersTab.month}</p><p className="text-lg font-semibold text-white">{overview.activeUsersThisMonth.toLocaleString()}</p></div>
                    </div>
                  </CardContent>
                </HeroCard>
                <KpiCard label={t.usersTab.dailyActiveUsers} value={overview.activeUsersToday.toLocaleString()} description={t.usersTab.loggedInToday} icon={<Activity className="size-8 bg-emerald-500 p-2 rounded-full text-white" />} />
                <KpiCard label={t.usersTab.weeklyActiveUsers} value={overview.activeUsersThisWeek.toLocaleString()} description={t.usersTab.activeThisWeek} icon={<Users className="size-8 bg-teal-500 p-2 rounded-full text-white" />} />
                <KpiCard label={t.usersTab.monthlyActiveUsers} value={overview.activeUsersThisMonth.toLocaleString()} description={t.usersTab.activeThisMonth} icon={<Users className="size-8 bg-cyan-600 p-2 rounded-full text-white" />} />
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.usersTab.newUsers}</CardTitle>
                    <CardDescription>{t.usersTab.userCreations}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[320px] min-h-[300px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <AreaChart data={filterTrends(userGrowth.dailyRegistrations)}>
                            <defs>
                              <linearGradient id="colorUsers" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#0f766e" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="#0f766e" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} tickMargin={8} />
                            <Tooltip {...tooltipStyle} />
                            <Area name={t.usersTab.growthChartName} type="monotone" dataKey="value" stroke="#0f766e" strokeWidth={2} fillOpacity={1} fill="url(#colorUsers)" />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[320px] rounded-xl" />}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.usersTab.activeShare}</CardTitle>
                    <CardDescription>{t.usersTab.activeShareDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="flex flex-col justify-center h-[320px]">
                    {mounted ? (
                      <div className="w-full h-[220px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <PieChart>
                            <Pie
                              data={[
                                { name: t.usersTab.today, value: overview.activeUsersToday },
                                { name: t.usersTab.week, value: overview.activeUsersThisWeek - overview.activeUsersToday },
                                { name: t.usersTab.month, value: overview.activeUsersThisMonth - overview.activeUsersThisWeek },
                                { name: t.usersTab.inactive, value: Math.max(overview.totalUsers - overview.activeUsersThisMonth, 0) },
                              ]}
                              cx="50%" cy="50%" innerRadius={60} outerRadius={80} paddingAngle={5} dataKey="value"
                            >
                              {[...Array(4)].map((_, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                            </Pie>
                            <Tooltip />
                          </PieChart>
                        </ResponsiveContainer>
                        <div className="grid grid-cols-2 gap-2 text-xs mt-4">
                          {[t.usersTab.today, t.usersTab.week, t.usersTab.month, t.usersTab.inactive].map((label, i) => (
                            <div key={label} className="flex items-center gap-1.5">
                              <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[i] }} />
                              <span>{label}: {i === 0 ? overview.activeUsersToday : i === 1 ? overview.activeUsersThisWeek : i === 2 ? overview.activeUsersThisMonth : Math.max(overview.totalUsers - overview.activeUsersThisMonth, 0)}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    ) : <Skeleton className="size-full rounded-full" />}
                  </CardContent>
                </Card>
              </div>
            </>
          ) : <div className="text-center p-6 text-muted-foreground">{t.usersTab.noStats}</div>}
        </TabsContent>

        {/* ══════════════════════════════════════════════════════════════════
            3. PROPERTIES
        ══════════════════════════════════════════════════════════════════ */}
        <TabsContent value="properties" className="flex flex-col gap-6">
          {loading ? <SkeletonGrid /> : properties && overview ? (
            <>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[minmax(150px,200px)]">
                <HeroCard tab="properties">
                  <CardHeader className="-pb-6">
                    <div className="flex justify-between items-start">
                      <div className="space-y-1">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-white/90">{t.propertiesTab.totalListings}</CardDescription>
                        <CardTitle className="text-4xl font-extrabold tracking-tight text-white">{overview.totalProperties.toLocaleString()}</CardTitle>
                      </div>
                      <div className="bg-white/20 rounded-full w-8 h-8 flex items-center justify-center">
                        <Building2 className="size-4 text-white" />
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex items-center gap-3 text-xs flex-wrap">
                      <span className="flex items-center gap-1.5"><span className="inline-flex size-2 rounded-full bg-emerald-400" /><span className="text-white/80">{t.propertiesTab.approvedListings}: <span className="font-semibold text-white">{overview.totalApprovedProperties.toLocaleString()}</span></span></span>
                      <span className="flex items-center gap-1.5"><span className="inline-flex size-2 rounded-full bg-amber-300" /><span className="text-white/80">{t.propertiesTab.pendingReview}: <span className="font-semibold text-white">{overview.totalPendingProperties.toLocaleString()}</span></span></span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 pt-1 border-t border-white/20">
                      <div><p className="text-xs text-white/70">{t.propertiesTab.rejectedListings}</p><p className="text-lg font-semibold text-white">{overview.totalRejectedProperties.toLocaleString()}</p></div>
                      <div>
                        <p className="text-xs text-white/70">Approval Rate</p>
                        <p className="text-lg font-semibold text-white">
                          {overview.totalProperties > 0 ? ((overview.totalApprovedProperties / overview.totalProperties) * 100).toFixed(1) : 0}%
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </HeroCard>
                <KpiCard label={t.propertiesTab.approvedListings} value={overview.totalApprovedProperties.toLocaleString()} description={t.propertiesTab.approvedDesc} icon={<Home className="size-8 bg-emerald-500 p-2 rounded-full text-white" />} />
                <KpiCard label={t.propertiesTab.pendingReview} value={overview.totalPendingProperties.toLocaleString()} description={t.propertiesTab.pendingDesc} icon={<AlertTriangle className="size-8 bg-amber-400 p-2 rounded-full text-white" />} />
                <KpiCard label={t.propertiesTab.rejectedListings} value={overview.totalRejectedProperties.toLocaleString()} description={t.propertiesTab.rejectedDesc} icon={<Home className="size-8 bg-rose-500 p-2 rounded-full text-white" />} />
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.propertiesTab.byType}</CardTitle>
                    <CardDescription>{t.propertiesTab.byTypeDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[320px] min-h-[300px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <BarChart data={Object.entries(properties.propertiesByType).map(([name, value]) => ({ name, value }))} margin={{ top: 8, right: 8, left: 0, bottom: 8 }}>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="name" tickLine={false} axisLine={false} tick={false} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip {...tooltipStyle} />
                            <Bar dataKey="value" radius={[6, 6, 0, 0]} minPointSize={48}
                              label={(props: any) => {
                                const { x, y, width, height, index } = props;
                                const entry = Object.entries(properties.propertiesByType)[index];
                                if (!entry || height < 32) return null;
                                const label = entry[0];
                                const truncated = label.length > 10 ? label.slice(0, 9) + "…" : label;
                                const pillW = Math.min(width - 8, truncated.length * 7 + 16);
                                const pillX = x + width / 2 - pillW / 2;
                                const pillY = y + 10;
                                return (
                                  <g>
                                    <rect x={pillX} y={pillY} width={pillW} height={18} rx={4} fill="rgba(255,255,255,0.18)" />
                                    <text x={pillX + pillW / 2} y={pillY + 13} textAnchor="middle" fill="#fff" fontSize={10} fontWeight={600} fontFamily="inherit">{truncated}</text>
                                  </g>
                                );
                              }}
                            >
                              {Object.entries(properties.propertiesByType).map((_, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                            </Bar>
                          </BarChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[320px] rounded-xl" />}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.propertiesTab.byStatus}</CardTitle>
                    <CardDescription>{t.propertiesTab.byStatusDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="flex flex-col justify-center items-center">
                    {mounted ? (
                      <div className="w-full h-[240px] flex items-center justify-center">
                        <ResponsiveContainer width="100%" height="100%">
                          <PieChart>
                            <Pie data={Object.entries(properties.propertiesByStatus).map(([name, value]) => ({ name, value }))} cx="50%" cy="50%" outerRadius={80} labelLine={false} dataKey="value" label={({ name, percent }) => `${name} (${((percent || 0) * 100).toFixed(0)}%)`}>
                              {Object.entries(properties.propertiesByStatus).map((_, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                            </Pie>
                            <Tooltip />
                          </PieChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="size-full rounded-full" />}
                  </CardContent>
                </Card>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.propertiesTab.overTime}</CardTitle>
                    <CardDescription>{t.propertiesTab.overTimeDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[300px] min-h-[250px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <AreaChart data={filterTrends(properties.propertiesCreatedOverTime)}>
                            <defs>
                              <linearGradient id="colorProps" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#7e22ce" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="#7e22ce" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip {...tooltipStyle} />
                            <Area name={t.propertiesTab.chartLabel} type="monotone" dataKey="value" stroke="#7e22ce" strokeWidth={2} fillOpacity={1} fill="url(#colorProps)" />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[300px] rounded-xl" />}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.propertiesTab.topCities}</CardTitle>
                    <CardDescription>{t.propertiesTab.topCitiesDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[300px] overflow-y-auto">
                    <Table>
                      <TableHeader><TableRow><TableHead>{t.propertiesTab.colCity}</TableHead><TableHead className="text-right">{t.propertiesTab.colListings}</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {Object.entries(properties.propertiesByCity).sort((a, b) => b[1] - a[1]).slice(0, 10).map(([city, count]) => (
                          <TableRow key={city}><TableCell className="font-semibold text-xs">{city}</TableCell><TableCell className="text-right font-mono text-xs">{count}</TableCell></TableRow>
                        ))}
                        {!Object.keys(properties.propertiesByCity).length && <TableRow><TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.propertiesTab.noCities}</TableCell></TableRow>}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : <div className="text-center p-6 text-muted-foreground">{t.propertiesTab.noAnalytics}</div>}
        </TabsContent>

        {/* ══════════════════════════════════════════════════════════════════
            4. REVENUE
        ══════════════════════════════════════════════════════════════════ */}
        <TabsContent value="revenue" className="flex flex-col gap-6">
          {loading ? <SkeletonGrid /> : revenue ? (
            <>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[minmax(150px,200px)]">
                <HeroCard tab="revenue">
                  <CardHeader className="-pb-6">
                    <div className="flex justify-between items-start">
                      <div className="space-y-1">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-white/90">{t.revenueTab.totalRevenue}</CardDescription>
                        <CardTitle className="text-4xl font-extrabold tracking-tight text-white">${revenue.boostPurchaseRevenue.toLocaleString()}</CardTitle>
                      </div>
                      <div className="bg-white/20 rounded-full w-8 h-8 flex items-center justify-center">
                        <DollarSign className="size-4 text-white" />
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex items-center gap-2 text-sm">
                      {revenue.revenueGrowth >= 0 ? <TrendingUp className="size-4 text-emerald-300" /> : <TrendingDown className="size-4 text-red-300" />}
                      <span className="text-white/90">{revenue.revenueGrowth >= 0 ? "+" : ""}{revenue.revenueGrowth.toFixed(1)}% {t.revenueTab.growthDesc}</span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 pt-1 border-t border-white/20">
                      <div><p className="text-xs text-white/70">{t.revenueTab.monetizedSellers}</p><p className="text-lg font-semibold text-white">{activeSellersCount}</p></div>
                      <div><p className="text-xs text-white/70">{t.revenueTab.growthMoM}</p><p className="text-lg font-semibold text-white">{revenue.revenueGrowth >= 0 ? "+" : ""}{revenue.revenueGrowth.toFixed(1)}%</p></div>
                    </div>
                  </CardContent>
                </HeroCard>

                <Card className="bg-white border-transparent h-full flex flex-col">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex h-full flex-col justify-between items-start">
                      <div className="flex justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">{t.revenueTab.growthMoM}</CardDescription>
                        {revenue.revenueGrowth >= 0 ? <TrendingUp className="size-8 bg-emerald-500 p-2 rounded-full text-white" /> : <TrendingDown className="size-8 bg-rose-500 p-2 rounded-full text-white" />}
                      </div>
                      <div className="relative top-8">
                        <CardTitle className={`text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight ${revenue.revenueGrowth >= 0 ? "text-emerald-600" : "text-rose-600"}`}>
                          {revenue.revenueGrowth >= 0 ? "+" : ""}{revenue.revenueGrowth.toFixed(1)}%
                        </CardTitle>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent><p className="text-xs text-muted-foreground">{t.revenueTab.growthDesc}</p></CardContent>
                </Card>

                <KpiCard label={t.revenueTab.monetizedSellers} value={activeSellersCount} description={t.revenueTab.purchasedSpots} icon={<Users className="size-8 bg-emerald-600 p-2 rounded-full text-white" />} />

                <Card className="bg-white border-transparent h-full flex flex-col">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex h-full flex-col justify-between items-start">
                      <div className="flex justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">Avg. Per Seller</CardDescription>
                        <DollarSign className="size-8 bg-teal-600 p-2 rounded-full text-white" />
                      </div>
                      <div className="relative top-8">
                        <CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">
                          ${activeSellersCount > 0 ? Math.round(revenue.boostPurchaseRevenue / activeSellersCount).toLocaleString() : 0}
                        </CardTitle>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent><p className="text-xs text-muted-foreground">Revenue per active seller</p></CardContent>
                </Card>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.revenueTab.monthlyEarnings}</CardTitle>
                    <CardDescription>{t.revenueTab.monthlyEarningsDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[320px] min-h-[300px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <BarChart data={Object.entries(revenue.monthlyRevenue).map(([month, val]) => ({ month, amount: parseFloat(val.toString()) }))}>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="month" tickLine={false} axisLine={false} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip {...tooltipStyle} formatter={(value) => `$${value}`} />
                            <Bar name={t.revenueTab.earningsChartName} dataKey="amount" radius={[6, 6, 0, 0]}>
                              {Object.entries(revenue.monthlyRevenue).map((_, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)}
                            </Bar>
                          </BarChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[320px] rounded-xl" />}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.revenueTab.premiumSellers}</CardTitle>
                    <CardDescription>{t.revenueTab.topSellersDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[320px] overflow-y-auto">
                    <Table>
                      <TableHeader><TableRow><TableHead>{t.revenueTab.colAgent}</TableHead><TableHead className="text-right">{t.revenueTab.colRevenue}</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {revenue.topSellers.map((s) => (
                          <TableRow key={s.sellerId}>
                            <TableCell className="py-2"><div className="flex flex-col"><span className="font-semibold text-xs text-foreground">{s.sellerName}</span><span className="text-[10px] text-muted-foreground">{s.sellerEmail}</span></div></TableCell>
                            <TableCell className="text-right font-mono font-bold text-xs text-emerald-600 py-2">${s.revenue.toLocaleString()}</TableCell>
                          </TableRow>
                        ))}
                        {!revenue.topSellers.length && <TableRow><TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.revenueTab.noTransactions}</TableCell></TableRow>}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : <div className="text-center p-6 text-muted-foreground">{t.revenueTab.noRecords}</div>}
        </TabsContent>

        {/* ══════════════════════════════════════════════════════════════════
            5. CHATS & ENGAGEMENT
        ══════════════════════════════════════════════════════════════════ */}
        <TabsContent value="chats" className="flex flex-col gap-6">
          {loading ? <SkeletonGrid /> : chats && engagement && overview ? (
            <>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[minmax(150px,200px)]">
                <HeroCard tab="chats">
                  <CardHeader className="-pb-6">
                    <div className="flex justify-between items-start">
                      <div className="space-y-1">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-white/90">{t.chatsTab.totalChats}</CardDescription>
                        <CardTitle className="text-4xl font-extrabold tracking-tight text-white">{overview.totalChats.toLocaleString()}</CardTitle>
                      </div>
                      <div className="bg-white/20 rounded-full w-8 h-8 flex items-center justify-center">
                        <MessageSquare className="size-4 text-white" />
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex items-center gap-2 text-sm">
                      <Activity className="size-4 text-blue-300" />
                      <span className="text-white/90">{t.chatsTab.convDesc.replace("{count}", String(overview.totalMessages))}</span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 pt-1 border-t border-white/20">
                      <div><p className="text-xs text-white/70">{t.chatsTab.totalMessages}</p><p className="text-lg font-semibold text-white">{overview.totalMessages.toLocaleString()}</p></div>
                      <div><p className="text-xs text-white/70">{t.chatsTab.totalFavorites}</p><p className="text-lg font-semibold text-white">{overview.totalFavorites.toLocaleString()}</p></div>
                    </div>
                  </CardContent>
                </HeroCard>
                <KpiCard label={t.chatsTab.totalMessages} value={overview.totalMessages.toLocaleString()} description={t.chatsTab.totalMessagesDesc} icon={<MessageSquare className="size-8 bg-blue-500 p-2 rounded-full text-white" />} />
                <KpiCard label={t.chatsTab.totalFavorites} value={overview.totalFavorites.toLocaleString()} description={t.chatsTab.totalFavoritesDesc} icon={<Heart className="size-8 bg-rose-500 p-2 rounded-full text-white" />} />
                <Card className="bg-white border-transparent h-full flex flex-col">
                  <CardHeader className="pb-3 flex-1">
                    <div className="flex h-full flex-col justify-between items-start">
                      <div className="flex justify-between items-center w-full">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/70">Avg. Messages / Chat</CardDescription>
                        <Activity className="size-8 bg-indigo-500 p-2 rounded-full text-white" />
                      </div>
                      <div className="relative top-8">
                        <CardTitle className="text-3xl sm:text-4xl lg:text-4xl font-extrabold tracking-tight">
                          {overview.totalChats > 0 ? (overview.totalMessages / overview.totalChats).toFixed(1) : "0"}
                        </CardTitle>
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent><p className="text-xs text-muted-foreground">Average messages per conversation</p></CardContent>
                </Card>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.chatsTab.messagesAct}</CardTitle>
                    <CardDescription>{t.chatsTab.frequencyDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[300px] min-h-[250px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <AreaChart data={filterTrends(chats.messagesPerDay)}>
                            <defs>
                              <linearGradient id="colorMsgs" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#1d4ed8" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="#1d4ed8" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip {...tooltipStyle} />
                            <Area name={t.chatsTab.messagesChartName} type="monotone" dataKey="value" stroke="#1d4ed8" strokeWidth={2} fillOpacity={1} fill="url(#colorMsgs)" />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[300px] rounded-xl" />}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.chatsTab.favsAction}</CardTitle>
                    <CardDescription>{t.chatsTab.favsDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[300px] min-h-[250px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <AreaChart data={filterTrends(engagement.favoritesTrends)}>
                            <defs>
                              <linearGradient id="colorFavs" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#e11d48" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="#e11d48" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip {...tooltipStyle} />
                            <Area name={t.chatsTab.favsChartName} type="monotone" dataKey="value" stroke="#e11d48" strokeWidth={2} fillOpacity={1} fill="url(#colorFavs)" />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[300px] rounded-xl" />}
                  </CardContent>
                </Card>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.chatsTab.mostViewed}</CardTitle>
                    <CardDescription>{t.chatsTab.mostViewedDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader><TableRow><TableHead>{t.chatsTab.colTitle}</TableHead><TableHead className="text-right">{t.chatsTab.colViews}</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {engagement.mostViewedProperties.map((p) => (
                          <TableRow key={p.propertyId}><TableCell className="font-semibold text-xs py-2 truncate max-w-[200px]">{p.propertyTitle}</TableCell><TableCell className="text-right font-mono font-bold text-xs text-blue-600 py-2">{p.count}</TableCell></TableRow>
                        ))}
                        {!engagement.mostViewedProperties.length && <TableRow><TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.chatsTab.noViews}</TableCell></TableRow>}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.chatsTab.mostFavorited}</CardTitle>
                    <CardDescription>{t.chatsTab.mostFavoritedDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader><TableRow><TableHead>{t.chatsTab.colTitle}</TableHead><TableHead className="text-right">{t.chatsTab.colFavorites}</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {engagement.mostFavoritedProperties.map((p) => (
                          <TableRow key={p.propertyId}><TableCell className="font-semibold text-xs py-2 truncate max-w-[200px]">{p.propertyTitle}</TableCell><TableCell className="text-right font-mono font-bold text-xs text-rose-600 py-2">{p.count}</TableCell></TableRow>
                        ))}
                        {!engagement.mostFavoritedProperties.length && <TableRow><TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.chatsTab.noFavorites}</TableCell></TableRow>}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : <div className="text-center p-6 text-muted-foreground">{t.chatsTab.noEngagement}</div>}
        </TabsContent>

        {/* ══════════════════════════════════════════════════════════════════
            6. MODERATION
        ══════════════════════════════════════════════════════════════════ */}
        <TabsContent value="moderation" className="flex flex-col gap-6">
          {loading ? <SkeletonGrid /> : moderation && overview ? (
            <>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[minmax(150px,200px)]">
                <HeroCard tab="moderation">
                  <CardHeader className="-pb-6">
                    <div className="flex justify-between items-start">
                      <div className="space-y-1">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-white/90">{t.moderationTab.approvalRateLabel}</CardDescription>
                        <CardTitle className="text-4xl font-extrabold tracking-tight text-white">{moderationDecisionStats.approvalRate.toFixed(1)}%</CardTitle>
                      </div>
                      <div className="bg-white/20 rounded-full w-8 h-8 flex items-center justify-center">
                        <ShieldCheck className="size-4 text-white" />
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex items-center gap-2 text-sm">
                      <span className="inline-flex size-2 rounded-full bg-red-300" />
                      <span className="text-white/90">{t.moderationTab.rejectionLabel}: {moderationDecisionStats.rejectionRate.toFixed(1)}%</span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 pt-1 border-t border-white/20">
                      <div><p className="text-xs text-white/70">{t.moderationTab.totalApprovals}</p><p className="text-lg font-semibold text-white">{moderationDecisionStats.approvals.toLocaleString()}</p></div>
                      <div><p className="text-xs text-white/70">{t.moderationTab.totalRejections}</p><p className="text-lg font-semibold text-white">{moderationDecisionStats.rejections.toLocaleString()}</p></div>
                    </div>
                  </CardContent>
                </HeroCard>
                <KpiCard label={t.moderationTab.totalApprovals} value={moderationDecisionStats.approvals.toLocaleString()} description={t.moderationTab.totalApprovalsDesc} icon={<Activity className="size-8 bg-emerald-500 p-2 rounded-full text-white" />} />
                <KpiCard label={t.moderationTab.totalRejections} value={moderationDecisionStats.rejections.toLocaleString()} description={t.moderationTab.totalRejectionsDesc} icon={<Flag className="size-8 bg-rose-500 p-2 rounded-full text-white" />} />
                <KpiCard label={t.moderationTab.activeAdmins} value={moderation.moderationActivity.length} description={t.moderationTab.activeAdminsDesc} icon={<ShieldCheck className="size-8 bg-amber-500 p-2 rounded-full text-white" />} />
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.moderationTab.approvalsTimeline}</CardTitle>
                    <CardDescription>{t.moderationTab.approvalsDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[300px] min-h-[250px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <AreaChart data={filterTrends(moderation.approvalsOverTime)}>
                            <defs>
                              <linearGradient id="colorApps" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#d97706" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="#d97706" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip {...tooltipStyle} />
                            <Area name={t.moderationTab.approvalsChartName} type="monotone" dataKey="value" stroke="#d97706" strokeWidth={2} fillOpacity={1} fill="url(#colorApps)" />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[300px] rounded-xl" />}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.moderationTab.rejectionRatio}</CardTitle>
                    <CardDescription>{t.moderationTab.rejectionDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="flex flex-col gap-4 pt-2">
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">{t.moderationTab.approvalRate}</span>
                      <Badge className="bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20">{moderationDecisionStats.approvalRate.toFixed(1)}%</Badge>
                    </div>
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">{t.moderationTab.rejectionLabel}</span>
                      <Badge className={moderationDecisionStats.rejectionRate > 20 ? "bg-rose-500/10 text-rose-500 border-rose-500/20" : "bg-amber-500/10 text-amber-500 border-amber-500/20"}>
                        {moderationDecisionStats.rejectionRate.toFixed(1)}%
                      </Badge>
                    </div>
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">{t.moderationTab.totalApprovals}</span>
                      <Badge className="bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20">{moderationDecisionStats.approvals}</Badge>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-muted-foreground">{t.moderationTab.activeAdmins}</span>
                      <Badge className="bg-amber-500/10 text-amber-700 border-amber-500/20">{moderation.moderationActivity.length}</Badge>
                    </div>
                    <p className="text-[10px] text-muted-foreground mt-2">{t.moderationTab.calculatedFrom}</p>
                  </CardContent>
                </Card>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.moderationTab.modActivity}</CardTitle>
                    <CardDescription>{t.moderationTab.activeModsDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[350px] overflow-y-auto">
                    <Table>
                      <TableHeader><TableRow><TableHead>{t.moderationTab.colMod}</TableHead><TableHead className="text-right">{t.moderationTab.colActions}</TableHead></TableRow></TableHeader>
                      <TableBody>
                        {moderation.moderationActivity.map((a) => (
                          <TableRow key={a.adminId}>
                            <TableCell className="py-2"><div className="flex flex-col"><span className="font-semibold text-xs text-foreground">{a.adminName}</span><span className="text-[10px] text-muted-foreground">{a.adminEmail}</span></div></TableCell>
                            <TableCell className="text-right font-mono font-bold text-xs text-amber-600 py-2">{a.actionCount}</TableCell>
                          </TableRow>
                        ))}
                        {!moderation.moderationActivity.length && <TableRow><TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.moderationTab.noModActivity}</TableCell></TableRow>}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>

                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.moderationTab.adminLogs}</CardTitle>
                    <CardDescription>{t.moderationTab.recentLogsDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[350px] overflow-y-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead className="w-[100px]">{t.moderationTab.colTime}</TableHead>
                          <TableHead className="w-[120px]">{t.moderationTab.colAdmin}</TableHead>
                          <TableHead className="w-[100px]">{t.moderationTab.colOperation}</TableHead>
                          <TableHead>{t.moderationTab.colDetails}</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {moderation.adminActivityLogs.slice(0, 15).map((log) => (
                          <TableRow key={log.id} className="text-xs">
                            <TableCell className="py-2 whitespace-nowrap text-muted-foreground text-[10px]">
                              {new Date(log.createdAt).toLocaleTimeString(dateLocale, { hour: "2-digit", minute: "2-digit" })}
                            </TableCell>
                            <TableCell className="py-2 truncate max-w-[100px] font-medium">{log.userName || "Admin"}</TableCell>
                            <TableCell className="py-2">
                              <Badge className={`text-[9px] px-1 py-0 ${log.activityType === "APPROVE" ? "bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20" : log.activityType === "REJECT" ? "bg-rose-500/10 text-rose-500 hover:bg-rose-500/20 border-rose-500/20" : "bg-muted text-muted-foreground border-muted-foreground/20"}`}>
                                {log.activityType}
                              </Badge>
                            </TableCell>
                            <TableCell className="py-2 text-[11px] max-w-[200px] truncate" title={log.description}>{log.description}</TableCell>
                          </TableRow>
                        ))}
                        {!moderation.adminActivityLogs.length && <TableRow><TableCell colSpan={4} className="text-center text-muted-foreground text-xs py-4">{t.moderationTab.noAuditLogs}</TableCell></TableRow>}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : <div className="text-center p-6 text-muted-foreground">{t.moderationTab.noRecords}</div>}
        </TabsContent>

        {/* ══════════════════════════════════════════════════════════════════
            7. MEDIA — slate/cyan hero
        ══════════════════════════════════════════════════════════════════ */}
        <TabsContent value="media" className="flex flex-col gap-6">
          {loading ? <SkeletonGrid /> : media ? (
            <>
              {/* ── KPI Row ── */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 auto-rows-[minmax(150px,200px)]">
                {/* Hero card — slate/cyan */}
                <HeroCard tab="media">
                  <CardHeader className="-pb-6">
                    <div className="flex justify-between items-start">
                      <div className="space-y-1">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider text-white/90">
                          {t.mediaTab.totalMedia}
                        </CardDescription>
                        <CardTitle className="text-4xl font-extrabold tracking-tight text-white">
                          {media.totalMediaFiles.toLocaleString()}
                        </CardTitle>
                      </div>
                      <div className="bg-white/20 rounded-full w-8 h-8 flex items-center justify-center">
                        <LayoutGrid className="size-4 text-white" />
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <div className="flex items-center gap-2 text-sm">
                      <FileImage className="size-4 text-cyan-300" />
                      <span className="text-white/90">
                        {media.totalImages.toLocaleString()} images · {media.totalVideos.toLocaleString()} videos
                      </span>
                    </div>
                    <div className="grid grid-cols-2 gap-4 pt-1 border-t border-white/20">
                      <div>
                        <p className="text-xs text-white/70">{t.mediaTab.avgPerProperty}</p>
                        <p className="text-lg font-semibold text-white">{media.averageMediaPerProperty.toFixed(1)}</p>
                      </div>
                      <div>
                        <p className="text-xs text-white/70">{t.mediaTab.noMediaProperties}</p>
                        <p className="text-lg font-semibold text-white">{media.propertiesWithNoMedia.toLocaleString()}</p>
                      </div>
                    </div>
                  </CardContent>
                </HeroCard>

                <KpiCard
                  label={t.mediaTab.totalImages}
                  value={media.totalImages.toLocaleString()}
                  description={t.mediaTab.totalImagesDesc}
                  icon={<Image className="size-8 bg-cyan-500 p-2 rounded-full text-white" />}
                />
                <KpiCard
                  label={t.mediaTab.totalVideos}
                  value={media.totalVideos.toLocaleString()}
                  description={t.mediaTab.totalVideosDesc}
                  icon={<Video className="size-8 bg-indigo-500 p-2 rounded-full text-white" />}
                />
                <KpiCard
                  label={t.mediaTab.noMediaProperties}
                  value={media.propertiesWithNoMedia.toLocaleString()}
                  description={t.mediaTab.noMediaPropertiesDesc}
                  icon={<AlertTriangle className="size-8 bg-rose-500 p-2 rounded-full text-white" />}
                />
              </div>

              {/* ── Charts Row ── */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Upload trend area chart */}
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.mediaTab.uploadTrend}</CardTitle>
                    <CardDescription>{t.mediaTab.uploadTrendDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    {mounted ? (
                      <div className="w-full h-[300px] min-h-[250px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <AreaChart data={filterTrends(media.mediaUploadedOverTime)}>
                            <defs>
                              <linearGradient id="colorMedia" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#06b6d4" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="#06b6d4" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip {...tooltipStyle} />
                            <Area
                              name={t.mediaTab.uploadChartName}
                              type="monotone"
                              dataKey="value"
                              stroke="#06b6d4"
                              strokeWidth={2}
                              fillOpacity={1}
                              fill="url(#colorMedia)"
                            />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : <Skeleton className="w-full h-[300px] rounded-xl" />}
                  </CardContent>
                </Card>

                {/* Media by type pie */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.mediaTab.byType}</CardTitle>
                    <CardDescription>{t.mediaTab.byTypeDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="flex flex-col justify-center items-center h-[300px]">
                    {mounted ? (
                      <>
                        <div className="w-full h-[200px]">
                          <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                              <Pie
                                data={Object.entries(media.mediaByType).map(([name, value]) => ({ name, value }))}
                                cx="50%"
                                cy="50%"
                                innerRadius={55}
                                outerRadius={80}
                                paddingAngle={4}
                                dataKey="value"
                              >
                                {Object.entries(media.mediaByType).map((_, index) => (
                                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                ))}
                              </Pie>
                              <Tooltip />
                            </PieChart>
                          </ResponsiveContainer>
                        </div>
                        <div className="flex flex-wrap justify-center gap-3 text-xs mt-2">
                          {Object.entries(media.mediaByType).map(([name, value], i) => (
                            <div key={name} className="flex items-center gap-1.5">
                              <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[i % COLORS.length] }} />
                              <span className="capitalize font-medium">{name}</span>
                              <span className="text-muted-foreground">({value.toLocaleString()})</span>
                            </div>
                          ))}
                        </div>
                      </>
                    ) : <Skeleton className="size-[200px] rounded-full" />}
                  </CardContent>
                </Card>
              </div>

              {/* ── Top Properties Table ── */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg font-bold">{t.mediaTab.topProperties}</CardTitle>
                  <CardDescription>{t.mediaTab.topPropertiesDesc}</CardDescription>
                </CardHeader>
                <CardContent>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead className="w-8">#</TableHead>
                        <TableHead>{t.mediaTab.colProperty}</TableHead>
                        <TableHead className="text-right">{t.mediaTab.colCount}</TableHead>
                        <TableHead className="w-[200px]">Distribution</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {media.topPropertiesByMediaCount.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={4} className="text-center text-muted-foreground text-xs py-6">
                            {t.mediaTab.noTopProperties}
                          </TableCell>
                        </TableRow>
                      ) : (
                        (() => {
                          const maxCount = Math.max(...media.topPropertiesByMediaCount.map((p) => p.mediaCount), 1);
                          return media.topPropertiesByMediaCount.map((p, i) => (
                            <TableRow key={p.propertyId}>
                              <TableCell className="text-xs font-mono text-muted-foreground py-2">{i + 1}</TableCell>
                              <TableCell className="py-2">
                                <span className="font-semibold text-xs text-foreground truncate max-w-[280px] block">{p.propertyTitle}</span>
                              </TableCell>
                              <TableCell className="text-right font-mono font-bold text-xs text-cyan-600 py-2">{p.mediaCount}</TableCell>
                              <TableCell className="py-2">
                                <div className="w-full bg-muted rounded-full h-1.5 overflow-hidden">
                                  <div
                                    className="h-full rounded-full"
                                    style={{
                                      width: `${(p.mediaCount / maxCount) * 100}%`,
                                      backgroundColor: COLORS[i % COLORS.length],
                                    }}
                                  />
                                </div>
                              </TableCell>
                            </TableRow>
                          ));
                        })()
                      )}
                    </TableBody>
                  </Table>
                </CardContent>
              </Card>
            </>
          ) : <div className="text-center p-6 text-muted-foreground">{t.mediaTab.noRecords}</div>}
        </TabsContent>
      </Tabs>

      <style jsx global>{`
        @media print {
          aside, header, .TabsList, .print\\:hidden, button { display: none !important; }
          body, html, main, .h-screen, .overflow-hidden {
            height: auto !important; overflow: visible !important;
            margin: 0 !important; padding: 0 !important;
            width: 100% !important; position: static !important; min-height: auto !important;
          }
          div[class*="ml-64"] { margin-left: 0 !important; }
          .recharts-responsive-container { width: 100% !important; height: 350px !important; }
        }
      `}</style>
    </div>
  );
}
