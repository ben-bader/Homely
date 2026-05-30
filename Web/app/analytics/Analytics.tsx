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
  Bell,
  AlertTriangle,
  Zap,
  DollarSign,
  Activity,
  Printer,
  RefreshCw,
  Clock,
  Search,
  FileSpreadsheet,
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
  LineChart,
  Line,
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
} from "@/services/adminStats";

type Language = "en" | "fr";

const dict = {
  en: {
    liveAnalytics: "System Live Analytics",
    title: "Centralized Platform Stats",
    subtitle: "Monitor real-time system metrics, registrations, property listings, and premium boost sales.",
    autoRefresh: "Auto Refresh",
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
      moderation: "Moderation"
    },
    overviewTab: {
      platformUsers: "Platform Users",
      activeToday: "{count} active on the platform today",
      listedProperties: "Listed Properties",
      approvedActive: "{count} Approved / Active",
      premiumBoostSales: "Premium Boost Sales",
      promoAdsDesc: "Total promotional items approved for highlight",
      platformRevenue: "Platform Revenue",
      generatedFrom: "Generated from {count} premium ads",
      propMod: "Property Moderation",
      propPendingDesc: "Properties currently pending admin validation.",
      reportsFlags: "Reports & Flags",
      reportsFlagsDesc: "Open tickets regarding bad listings/behavior.",
      convOpened: "Conversations Opened",
      convDesc: "Generating {count} message exchanges.",
      monthlyActive: "Monthly Active Users",
      retentionDesc: "Retention of {pct}% of users.",
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
      noOverviewStats: "No overview stats found."
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
      noStats: "No user statistics found."
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
      chartLabel: "New Listings"
    },
    revenueTab: {
      totalRevenue: "Total Boost Ad Revenue",
      completedPurchases: "All completed purchases of premium listings.",
      growthMoM: "Revenue Growth MoM",
      growthDesc: "Month-over-month growth of promotional sales.",
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
      noRecords: "No financial records found."
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
      noEngagement: "No engagement stats found."
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
      noRecords: "No moderation records found."
    },
    errorTitle: "Analytics Loading Failed",
    retryBtn: "Retry Loading"
  },
  fr: {
    liveAnalytics: "Analyses Système en Direct",
    title: "Statistiques Centralisées",
    subtitle: "Suivez en temps réel les indicateurs système, les inscriptions, les annonces immobilières et les ventes de boosts premium.",
    autoRefresh: "Rafraîchir auto",
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
      moderation: "Modération"
    },
    overviewTab: {
      platformUsers: "Utilisateurs",
      activeToday: "{count} actifs sur la plateforme aujourd'hui",
      listedProperties: "Propriétés Répertoriées",
      approvedActive: "{count} Approuvées / Actives",
      premiumBoostSales: "Ventes de Boosts Premium",
      promoAdsDesc: "Total des annonces promotionnelles approuvées pour mise en avant",
      platformRevenue: "Revenus de la Plateforme",
      generatedFrom: "Générés à partir de {count} annonces premium",
      propMod: "Modération de Propriétés",
      propPendingDesc: "Propriétés en attente de validation par les administrateurs.",
      reportsFlags: "Signalements & Plaintes",
      reportsFlagsDesc: "Tickets ouverts concernant de mauvaises annonces ou comportements.",
      convOpened: "Conversations Ouvertes",
      convDesc: "Générant {count} échanges de messages.",
      monthlyActive: "Utilisateurs Actifs Mensuels",
      retentionDesc: "Rétention de {pct}% des utilisateurs.",
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
      noOverviewStats: "Aucune statistique générale trouvée."
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
      noStats: "Aucune statistique utilisateur trouvée."
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
      chartLabel: "Nouvelles Annonces"
    },
    revenueTab: {
      totalRevenue: "Revenus Publicitaires Totaux",
      completedPurchases: "Tous les achats d'annonces premium complétés.",
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
      noRecords: "Aucun enregistrement financier trouvé."
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
      noEngagement: "Aucune statistique d'engagement trouvée."
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
      noRecords: "Aucun enregistrement de modération trouvé."
    },
    errorTitle: "Échec du Chargement des Analyses",
    retryBtn: "Réessayer le Chargement"
  }
};

const COLORS = [
  "hsl(var(--primary))",
  "oklch(0.627 0.265 303.9)", // Sleek Violet
  "oklch(0.609 0.126 135.58)", // Slate green
  "oklch(0.704 0.191 22.21)", // Rust orange
  "oklch(0.479 0.15 247.96)", // Darker blue
  "oklch(0.609 0.25 0.0)", // Hot red
  "oklch(0.852 0.199 81.91)", // Warm yellow
];

export default function Analytics() {
  const locale = useLocale();
  const lang = (locale === "fr" ? "fr" : "en") as Language;
  const t = dict[lang];
  const dateLocale = lang === "fr" ? "fr-FR" : "en-US";

  // Mounting Guard
  const [mounted, setMounted] = useState(false);

  // States for stats datasets
  const [overview, setOverview] = useState<OverviewStats | null>(null);
  const [userGrowth, setUserGrowth] = useState<UserGrowthStats | null>(null);
  const [properties, setProperties] = useState<PropertyStats | null>(null);
  const [revenue, setRevenue] = useState<RevenueStats | null>(null);
  const [chats, setChats] = useState<ChatAnalytics | null>(null);
  const [engagement, setEngagement] = useState<EngagementStats | null>(null);
  const [moderation, setModeration] = useState<ModerationAnalytics | null>(null);

  // General App states
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [timeRange, setTimeRange] = useState<"7d" | "30d" | "all">("30d");
  const [activeTab, setActiveTab] = useState("overview");
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [autoRefresh, setAutoRefresh] = useState(false);

  // Initial mount setting
  useEffect(() => {
    setMounted(true);
  }, []);

  // Fetch all analytics datasets simultaneously
  const fetchAllData = useCallback(async (isSilent = false) => {
    if (!isSilent) setLoading(true);
    setError(null);
    try {
      const [
        overviewRes,
        growthRes,
        propsRes,
        revRes,
        chatsRes,
        engRes,
        modRes,
      ] = await Promise.all([
        adminStatsService.getOverview(),
        adminStatsService.getUserGrowth(),
        adminStatsService.getProperties(),
        adminStatsService.getRevenue(),
        adminStatsService.getChats(),
        adminStatsService.getEngagement(),
        adminStatsService.getModeration(),
      ]);

      setOverview(overviewRes);
      setUserGrowth(growthRes);
      setProperties(propsRes);
      setRevenue(revRes);
      setChats(chatsRes);
      setEngagement(engRes);
      setModeration(modRes);
    } catch (err: any) {
      console.error("Failed to load dashboard analytics:", err);
      setError(
        err?.response?.data?.message ||
          err?.message ||
          (lang === "fr" ? "Échec du chargement des statistiques. Veuillez réessayer." : "Failed to load analytics dashboard datasets. Please try again.")
      );
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }, [lang]);

  // Run on mount
  useEffect(() => {
    fetchAllData();
  }, [fetchAllData]);

  // Handle auto-refresh interval
  useEffect(() => {
    if (!autoRefresh) return;
    const interval = setInterval(() => {
      setIsRefreshing(true);
      fetchAllData(true);
    }, 15000); // refresh every 15s

    return () => clearInterval(interval);
  }, [autoRefresh, fetchAllData]);

  // Click handler for manual refresh
  const handleManualRefresh = () => {
    setIsRefreshing(true);
    fetchAllData();
  };

  // CSV Export utility
  const handleExportCSV = () => {
    let dataset: any[] = [];
    let filename = `homely_analytics_${activeTab}`;

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
      dataset = Object.entries(userGrowth.dailyRegistrations).map(([date, val]) => ({
        Date: date,
        Registrations: val,
      }));
    } else if (activeTab === "properties" && properties) {
      dataset = Object.entries(properties.propertiesByType).map(([type, val]) => ({
        PropertyType: type,
        ListingCount: val,
      }));
    } else if (activeTab === "revenue" && revenue) {
      dataset = revenue.topSellers.map((s, index) => ({
        Rank: index + 1,
        SellerName: s.sellerName,
        SellerEmail: s.sellerEmail,
        TotalRevenueUSD: s.revenue,
      }));
    } else if (activeTab === "chats" && chats) {
      dataset = chats.mostActiveUsers.map((u, index) => ({
        Rank: index + 1,
        UserName: u.userName,
        UserEmail: u.userEmail,
        MessagesSent: u.messageCount,
      }));
    } else if (activeTab === "moderation" && moderation) {
      dataset = moderation.adminActivityLogs.map(l => ({
        Time: new Date(l.createdAt).toLocaleString(dateLocale),
        AdminName: l.userName,
        Action: l.activityType,
        Entity: l.entityType,
        Description: l.description,
      }));
    }

    if (!dataset.length) {
      alert(lang === "fr" ? "Aucune donnée disponible pour l'export dans cette catégorie." : "No data available for export in this category.");
      return;
    }

    const headers = Object.keys(dataset[0]).join(",");
    const rows = dataset.map(obj =>
      Object.values(obj)
        .map(val => `"${String(val).replace(/"/g, '""')}"`)
        .join(",")
    );
    const csvContent = "data:text/csv;charset=utf-8," + [headers, ...rows].join("\n");
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `${filename}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // PDF Export trigger via window printing
  const handlePrintPDF = () => {
    window.print();
  };

  // Client time range filtering for Maps/Trends
  const filterTrends = <T extends number | string>(
    trendData: Record<string, T> | undefined
  ): Array<{ date: string; value: number }> => {
    if (!trendData) return [];
    const entries = Object.entries(trendData).map(([date, val]) => ({
      date,
      value: typeof val === "number" ? val : parseFloat(val.toString()),
    }));

    if (timeRange === "7d") {
      return entries.slice(-7);
    } else if (timeRange === "30d") {
      return entries.slice(-30);
    }
    return entries;
  };

  // Computed growth rates and metrics
  const activeSellersCount = useMemo(() => {
    if (!revenue) return 0;
    return revenue.topSellers.length;
  }, [revenue]);

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
    <div className="flex flex-col gap-6 p-4 md:p-6 w-full max-w-7xl mx-auto print:p-0 print:max-w-full">
      {/* Sleek dashboard header */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 border-b pb-6 print:border-none">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <Badge variant="secondary" className="bg-primary/10 text-primary hover:bg-primary/20 border-primary/20 font-semibold gap-1.5 py-0.5">
              <span className="relative flex size-2">
                <span className={`absolute inline-flex h-full w-full rounded-full bg-primary opacity-75 ${autoRefresh ? 'animate-ping' : ''}`}></span>
                <span className="relative inline-flex rounded-full size-2 bg-primary"></span>
              </span>
              {t.liveAnalytics}
            </Badge>
          </div>
          <h1 className="text-3xl font-extrabold tracking-tight bg-linear-to-r from-foreground to-foreground/75 bg-clip-text">
            {t.title}
          </h1>
          <p className="text-muted-foreground text-sm">
            {t.subtitle}
          </p>
        </div>

        {/* Global actions bar */}
        <div className="flex flex-wrap items-center gap-2 print:hidden">
          <div className="flex items-center gap-2 mr-2 bg-muted/50 border rounded-lg px-3 py-1.5 text-xs text-muted-foreground">
            <Clock className="size-3.5" />
            <span>{t.autoRefresh}</span>
            <input
              type="checkbox"
              checked={autoRefresh}
              onChange={(e) => setAutoRefresh(e.target.checked)}
              className="ml-1 rounded accent-primary cursor-pointer size-3.5"
            />
          </div>

          <Button
            variant="outline"
            size="sm"
            onClick={handleManualRefresh}
            disabled={isRefreshing || loading}
            className="gap-2 text-xs font-semibold h-9"
          >
            <RefreshCw className={`size-3.5 ${isRefreshing ? "animate-spin" : ""}`} />
            {t.refresh}
          </Button>

          <Button
            variant="outline"
            size="sm"
            onClick={handleExportCSV}
            disabled={loading}
            className="gap-2 text-xs font-semibold h-9"
          >
            <FileSpreadsheet className="size-3.5 text-emerald-600" />
            {t.exportCsv}
          </Button>

          <Button
            variant="outline"
            size="sm"
            onClick={handlePrintPDF}
            disabled={loading}
            className="gap-2 text-xs font-semibold h-9"
          >
            <Printer className="size-3.5 text-primary" />
            {t.printReport}
          </Button>
        </div>
      </div>

      {/* Date Range Selector */}
      <div className="flex items-center gap-2 bg-muted/40 p-1 border rounded-lg self-start print:hidden">
        <Button
          variant={timeRange === "7d" ? "secondary" : "ghost"}
          size="sm"
          className="text-xs py-1 h-7 font-medium px-3"
          onClick={() => setTimeRange("7d")}
        >
          {t.last7Days}
        </Button>
        <Button
          variant={timeRange === "30d" ? "secondary" : "ghost"}
          size="sm"
          className="text-xs py-1 h-7 font-medium px-3"
          onClick={() => setTimeRange("30d")}
        >
          {t.last30Days}
        </Button>
        <Button
          variant={timeRange === "all" ? "secondary" : "ghost"}
          size="sm"
          className="text-xs py-1 h-7 font-medium px-3"
          onClick={() => setTimeRange("all")}
        >
          {t.allTime}
        </Button>
      </div>

      {/* TABS CONTAINER */}
      <Tabs defaultValue="overview" onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid grid-cols-3 md:grid-flow-col auto-cols-max gap-1 bg-muted/65 p-1 border h-auto mb-6 print:hidden">
          <TabsTrigger value="overview" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">{t.tabs.overview}</TabsTrigger>
          <TabsTrigger value="users" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">{t.tabs.users}</TabsTrigger>
          <TabsTrigger value="properties" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">{t.tabs.properties}</TabsTrigger>
          <TabsTrigger value="revenue" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">{t.tabs.revenue}</TabsTrigger>
          <TabsTrigger value="chats" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">{t.tabs.chats}</TabsTrigger>
          <TabsTrigger value="moderation" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">{t.tabs.moderation}</TabsTrigger>
        </TabsList>

        {/* -------------------- 1. OVERVIEW TAB -------------------- */}
        <TabsContent value="overview" className="flex flex-col gap-6">
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              {[...Array(8)].map((_, i) => (
                <Card key={i} className="bg-muted/15 border-muted/50">
                  <CardHeader className="pb-2">
                    <Skeleton className="h-4 w-28 mb-1" />
                    <Skeleton className="h-8 w-20" />
                  </CardHeader>
                  <CardContent>
                    <Skeleton className="h-3 w-36" />
                  </CardContent>
                </Card>
              ))}
            </div>
          ) : overview ? (
            <>
              {/* KPIs Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <Card className="bg-linear-to-b from-primary/5 to-transparent border-primary/10 shadow-xs hover:shadow-md transition-all">
                  <CardHeader className="pb-2">
                    <div className="flex justify-between items-center">
                      <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">{t.overviewTab.platformUsers}</CardDescription>
                      <Users className="size-4 text-primary" />
                    </div>
                    <CardTitle className="text-3xl font-extrabold tracking-tight">{overview.totalUsers}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <Activity className="size-3 text-emerald-600 animate-pulse" />
                      <span>{t.overviewTab.activeToday.replace("{count}", String(overview.activeUsersToday))}</span>
                    </div>
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-violet-500/5 to-transparent border-violet-500/10 shadow-xs hover:shadow-md transition-all">
                  <CardHeader className="pb-2">
                    <div className="flex justify-between items-center">
                      <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">{t.overviewTab.listedProperties}</CardDescription>
                      <Home className="size-4 text-violet-500" />
                    </div>
                    <CardTitle className="text-3xl font-extrabold tracking-tight">{overview.totalProperties}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    <div className="flex items-center gap-1.5">
                      <span className="inline-flex size-2 rounded-full bg-emerald-500"></span>
                      <span>{t.overviewTab.approvedActive.replace("{count}", String(overview.totalApprovedProperties))}</span>
                    </div>
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-amber-500/5 to-transparent border-amber-500/10 shadow-xs hover:shadow-md transition-all">
                  <CardHeader className="pb-2">
                    <div className="flex justify-between items-center">
                      <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">{t.overviewTab.premiumBoostSales}</CardDescription>
                      <Zap className="size-4 text-amber-500 animate-pulse" />
                    </div>
                    <CardTitle className="text-3xl font-extrabold tracking-tight">{overview.totalBoostPurchases}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    <span className="font-semibold text-foreground">{t.overviewTab.promoAdsDesc}</span>
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-emerald-500/5 to-transparent border-emerald-500/10 shadow-xs hover:shadow-md transition-all">
                  <CardHeader className="pb-2">
                    <div className="flex justify-between items-center">
                      <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">{t.overviewTab.platformRevenue}</CardDescription>
                      <DollarSign className="size-4 text-emerald-500" />
                    </div>
                    <CardTitle className="text-3xl font-extrabold tracking-tight text-emerald-600">${overview.totalRevenue.toLocaleString()}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    <span>{t.overviewTab.generatedFrom.replace("{count}", String(overview.totalBoostPurchases))}</span>
                  </CardContent>
                </Card>
              </div>

              {/* Second Level Grid: Moderation, active rates */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <Card className="bg-muted/10 border-muted/50 hover:shadow-xs transition-all">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs font-semibold uppercase tracking-wider">{t.overviewTab.propMod}</CardDescription>
                    <CardTitle className="text-2xl font-bold">{overview.totalPendingProperties}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    {t.overviewTab.propPendingDesc}
                  </CardContent>
                </Card>

                <Card className="bg-muted/10 border-muted/50 hover:shadow-xs transition-all">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs font-semibold uppercase tracking-wider">{t.overviewTab.reportsFlags}</CardDescription>
                    <CardTitle className="text-2xl font-bold">{overview.totalReports}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    {t.overviewTab.reportsFlagsDesc}
                  </CardContent>
                </Card>

                <Card className="bg-muted/10 border-muted/50 hover:shadow-xs transition-all">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs font-semibold uppercase tracking-wider">{t.overviewTab.convOpened}</CardDescription>
                    <CardTitle className="text-2xl font-bold">{overview.totalChats}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    {t.overviewTab.convDesc.replace("{count}", String(overview.totalMessages))}
                  </CardContent>
                </Card>

                <Card className="bg-muted/10 border-muted/50 hover:shadow-xs transition-all">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs font-semibold uppercase tracking-wider">{t.overviewTab.monthlyActive}</CardDescription>
                    <CardTitle className="text-2xl font-bold">{overview.activeUsersThisMonth}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    {t.overviewTab.retentionDesc.replace("{pct}", ((overview.activeUsersThisMonth / Math.max(overview.totalUsers, 1)) * 100).toFixed(1))}
                  </CardContent>
                </Card>
              </div>

              {/* Sparkline & Highlights */}
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
                                <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} tickMargin={8} />
                            <Tooltip
                              contentStyle={{
                                background: "hsl(var(--background))",
                                border: "1px solid hsl(var(--border))",
                                borderRadius: "8px",
                              }}
                            />
                            <Area
                              name={t.overviewTab.registrationsName}
                              type="monotone"
                              dataKey="value"
                              stroke="hsl(var(--primary))"
                              strokeWidth={2}
                              fillOpacity={1}
                              fill="url(#colorRegs)"
                            />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : (
                      <Skeleton className="w-full h-[320px] rounded-xl" />
                    )}
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
          ) : (
            <div className="text-center p-6 text-muted-foreground">{t.overviewTab.noOverviewStats}</div>
          )}
        </TabsContent>

        {/* -------------------- 2. USER GROWTH TAB -------------------- */}
        <TabsContent value="users" className="flex flex-col gap-6">
          {loading ? (
            <Card>
              <CardContent className="pt-6">
                <Skeleton className="w-full h-[350px] rounded-xl" />
              </CardContent>
            </Card>
          ) : userGrowth ? (
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Daily Registration Chart */}
              <Card className="col-span-2">
                <CardHeader>
                  <CardTitle className="text-lg font-bold">{t.usersTab.newUsers}</CardTitle>
                  <CardDescription>{t.usersTab.userCreations}</CardDescription>
                </CardHeader>
                <CardContent>
                  {mounted ? (
                    <div className="w-full h-[350px] min-h-[300px]">
                      <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={filterTrends(userGrowth.dailyRegistrations)}>
                          <defs>
                            <linearGradient id="colorUsers" x1="0" y1="0" x2="0" y2="1">
                              <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.4} />
                              <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.0} />
                            </linearGradient>
                          </defs>
                          <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                          <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                          <YAxis tickLine={false} axisLine={false} tickMargin={8} />
                          <Tooltip
                            contentStyle={{
                              background: "hsl(var(--background))",
                              border: "1px solid hsl(var(--border))",
                              borderRadius: "8px",
                            }}
                          />
                          <Area
                            name={t.usersTab.growthChartName}
                            type="monotone"
                            dataKey="value"
                            stroke="hsl(var(--primary))"
                            strokeWidth={2}
                            fillOpacity={1}
                            fill="url(#colorUsers)"
                          />
                        </AreaChart>
                      </ResponsiveContainer>
                    </div>
                  ) : (
                    <Skeleton className="w-full h-[350px] rounded-xl" />
                  )}
                </CardContent>
              </Card>

              {/* Monthly Active vs Total */}
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg font-bold">{t.usersTab.activeShare}</CardTitle>
                  <CardDescription>{t.usersTab.activeShareDesc}</CardDescription>
                </CardHeader>
                <CardContent className="flex flex-col justify-center h-[350px]">
                  {mounted && overview ? (
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
                            cx="50%"
                            cy="50%"
                            innerRadius={60}
                            outerRadius={80}
                            paddingAngle={5}
                            dataKey="value"
                          >
                            {[...Array(4)].map((_, index) => (
                              <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                            ))}
                          </Pie>
                          <Tooltip />
                        </PieChart>
                      </ResponsiveContainer>
                      <div className="grid grid-cols-2 gap-2 text-xs mt-4">
                        <div className="flex items-center gap-1.5">
                          <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[0] }}></span>
                          <span>{t.usersTab.today}: {overview.activeUsersToday}</span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[1] }}></span>
                          <span>{t.usersTab.week}: {overview.activeUsersThisWeek}</span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[2] }}></span>
                          <span>{t.usersTab.month}: {overview.activeUsersThisMonth}</span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[3] }}></span>
                          <span>{t.usersTab.inactive}: {Math.max(overview.totalUsers - overview.activeUsersThisMonth, 0)}</span>
                        </div>
                      </div>
                    </div>
                  ) : (
                    <Skeleton className="size-full rounded-full" />
                  )}
                </CardContent>
              </Card>
            </div>
          ) : (
            <div className="text-center p-6 text-muted-foreground">{t.usersTab.noStats}</div>
          )}
        </TabsContent>

        {/* -------------------- 3. PROPERTY STATS TAB -------------------- */}
        <TabsContent value="properties" className="flex flex-col gap-6">
          {loading ? (
            <Card>
              <CardContent className="pt-6">
                <Skeleton className="w-full h-[350px] rounded-xl" />
              </CardContent>
            </Card>
          ) : properties ? (
            <>
              {/* Type and status charts */}
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
                          <BarChart data={Object.entries(properties.propertiesByType).map(([name, value]) => ({ name, value }))}>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="name" tickLine={false} axisLine={false} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip />
                            <Bar dataKey="value" radius={[6, 6, 0, 0]}>
                              {Object.entries(properties.propertiesByType).map((_, index) => (
                                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                              ))}
                            </Bar>
                          </BarChart>
                        </ResponsiveContainer>
                      </div>
                    ) : (
                      <Skeleton className="w-full h-[320px] rounded-xl" />
                    )}
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
                            <Pie
                              data={Object.entries(properties.propertiesByStatus).map(([name, value]) => ({ name, value }))}
                              cx="50%"
                              cy="50%"
                              outerRadius={80}
                              labelLine={false}
                              dataKey="value"
                              label={({ name, percent }) => `${name} (${((percent || 0) * 100).toFixed(0)}%)`}
                            >
                              {Object.entries(properties.propertiesByStatus).map((_, index) => (
                                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                              ))}
                            </Pie>
                            <Tooltip />
                          </PieChart>
                        </ResponsiveContainer>
                      </div>
                    ) : (
                      <Skeleton className="size-full rounded-full" />
                    )}
                  </CardContent>
                </Card>
              </div>

              {/* City distribution and trends */}
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
                          <LineChart data={filterTrends(properties.propertiesCreatedOverTime)}>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip />
                            <Line
                              name={t.propertiesTab.chartLabel}
                              type="monotone"
                              dataKey="value"
                              stroke="oklch(0.627 0.265 303.9)"
                              strokeWidth={3}
                              dot={false}
                            />
                          </LineChart>
                        </ResponsiveContainer>
                      </div>
                    ) : (
                      <Skeleton className="w-full h-[300px] rounded-xl" />
                    )}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.propertiesTab.topCities}</CardTitle>
                    <CardDescription>{t.propertiesTab.topCitiesDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[300px] overflow-y-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>{t.propertiesTab.colCity}</TableHead>
                          <TableHead className="text-right">{t.propertiesTab.colListings}</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {Object.entries(properties.propertiesByCity)
                          .sort((a, b) => b[1] - a[1])
                          .slice(0, 10)
                          .map(([city, count]) => (
                            <TableRow key={city}>
                              <TableCell className="font-semibold text-xs">{city}</TableCell>
                              <TableCell className="text-right font-mono text-xs">{count}</TableCell>
                            </TableRow>
                          ))}
                        {!Object.keys(properties.propertiesByCity).length && (
                          <TableRow>
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.propertiesTab.noCities}</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">{t.propertiesTab.noAnalytics}</div>
          )}
        </TabsContent>

        {/* -------------------- 4. REVENUE TAB -------------------- */}
        <TabsContent value="revenue" className="flex flex-col gap-6">
          {loading ? (
            <Card>
              <CardContent className="pt-6">
                <Skeleton className="w-full h-[350px] rounded-xl" />
              </CardContent>
            </Card>
          ) : revenue ? (
            <>
              {/* Financial KPIs */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <Card className="bg-linear-to-b from-emerald-500/5 to-transparent border-emerald-500/10 shadow-xs">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs uppercase font-semibold">{t.revenueTab.totalRevenue}</CardDescription>
                    <CardTitle className="text-4xl font-extrabold tracking-tight text-emerald-600">
                      ${revenue.boostPurchaseRevenue.toLocaleString()}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    {t.revenueTab.completedPurchases}
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-primary/5 to-transparent border-primary/10 shadow-xs">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs uppercase font-semibold">{t.revenueTab.growthMoM}</CardDescription>
                    <CardTitle className="text-4xl font-extrabold tracking-tight flex items-center gap-1">
                      {revenue.revenueGrowth >= 0 ? (
                        <>
                          <TrendingUp className="size-8 text-emerald-500 inline" />
                          <span className="text-emerald-600">+{revenue.revenueGrowth.toFixed(1)}%</span>
                        </>
                      ) : (
                        <>
                          <TrendingDown className="size-8 text-destructive inline" />
                          <span className="text-destructive">{revenue.revenueGrowth.toFixed(1)}%</span>
                        </>
                      )}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    {t.revenueTab.growthDesc}
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-violet-500/5 to-transparent border-violet-500/10 shadow-xs">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs uppercase font-semibold">{t.revenueTab.monetizedSellers}</CardDescription>
                    <CardTitle className="text-4xl font-extrabold tracking-tight text-violet-600">
                      {activeSellersCount}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    {t.revenueTab.purchasedSpots}
                  </CardContent>
                </Card>
              </div>

              {/* Monthly Revenue chart & top sellers */}
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
                            <Tooltip formatter={(value) => `$${value}`} />
                            <Bar name={t.revenueTab.earningsChartName} dataKey="amount" fill="hsl(var(--primary))" radius={[6, 6, 0, 0]} />
                          </BarChart>
                        </ResponsiveContainer>
                      </div>
                    ) : (
                      <Skeleton className="w-full h-[320px] rounded-xl" />
                    )}
                  </CardContent>
                </Card>

                {/* Top Sellers leaderboard */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.revenueTab.premiumSellers}</CardTitle>
                    <CardDescription>{t.revenueTab.topSellersDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[320px] overflow-y-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>{t.revenueTab.colAgent}</TableHead>
                          <TableHead className="text-right">{t.revenueTab.colRevenue}</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {revenue.topSellers.map((s) => (
                          <TableRow key={s.sellerId}>
                            <TableCell className="py-2">
                              <div className="flex flex-col">
                                <span className="font-semibold text-xs text-foreground">{s.sellerName}</span>
                                <span className="text-[10px] text-muted-foreground">{s.sellerEmail}</span>
                              </div>
                            </TableCell>
                            <TableCell className="text-right font-mono font-bold text-xs text-emerald-600 py-2">
                              ${s.revenue.toLocaleString()}
                            </TableCell>
                          </TableRow>
                        ))}
                        {!revenue.topSellers.length && (
                          <TableRow>
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.revenueTab.noTransactions}</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">{t.revenueTab.noRecords}</div>
          )}
        </TabsContent>

        {/* -------------------- 5. CHATS & ENGAGEMENT TAB -------------------- */}
        <TabsContent value="chats" className="flex flex-col gap-6">
          {loading ? (
            <Card>
              <CardContent className="pt-6">
                <Skeleton className="w-full h-[350px] rounded-xl" />
              </CardContent>
            </Card>
          ) : chats && engagement ? (
            <>
              {/* Daily messages chart & favorites trends */}
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
                                <stop offset="5%" stopColor="oklch(0.627 0.265 303.9)" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="oklch(0.627 0.265 303.9)" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip />
                            <Area
                              name={t.chatsTab.messagesChartName}
                              type="monotone"
                              dataKey="value"
                              stroke="oklch(0.627 0.265 303.9)"
                              strokeWidth={2}
                              fillOpacity={1}
                              fill="url(#colorMsgs)"
                            />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : (
                      <Skeleton className="w-full h-[300px] rounded-xl" />
                    )}
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
                          <LineChart data={filterTrends(engagement.favoritesTrends)}>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip />
                            <Line
                              name={t.chatsTab.favsChartName}
                              type="monotone"
                              dataKey="value"
                              stroke="oklch(0.609 0.25 0.0)"
                              strokeWidth={3}
                              dot={false}
                            />
                          </LineChart>
                        </ResponsiveContainer>
                      </div>
                    ) : (
                      <Skeleton className="w-full h-[300px] rounded-xl" />
                    )}
                  </CardContent>
                </Card>
              </div>

              {/* Leaderboards for Properties Views & Favorites */}
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.chatsTab.mostViewed}</CardTitle>
                    <CardDescription>{t.chatsTab.mostViewedDesc}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>{t.chatsTab.colTitle}</TableHead>
                          <TableHead className="text-right">{t.chatsTab.colViews}</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {engagement.mostViewedProperties.map((p) => (
                          <TableRow key={p.propertyId}>
                            <TableCell className="font-semibold text-xs py-2 truncate max-w-[200px]">{p.propertyTitle}</TableCell>
                            <TableCell className="text-right font-mono font-bold text-xs text-primary py-2">{p.count}</TableCell>
                          </TableRow>
                        ))}
                        {!engagement.mostViewedProperties.length && (
                          <TableRow>
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.chatsTab.noViews}</TableCell>
                          </TableRow>
                        )}
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
                      <TableHeader>
                        <TableRow>
                          <TableHead>{t.chatsTab.colTitle}</TableHead>
                          <TableHead className="text-right">{t.chatsTab.colFavorites}</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {engagement.mostFavoritedProperties.map((p) => (
                          <TableRow key={p.propertyId}>
                            <TableCell className="font-semibold text-xs py-2 truncate max-w-[200px]">{p.propertyTitle}</TableCell>
                            <TableCell className="text-right font-mono font-bold text-xs text-rose-600 py-2">{p.count}</TableCell>
                          </TableRow>
                        ))}
                        {!engagement.mostFavoritedProperties.length && (
                          <TableRow>
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.chatsTab.noFavorites}</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">{t.chatsTab.noEngagement}</div>
          )}
        </TabsContent>

        {/* -------------------- 6. MODERATION TAB -------------------- */}
        <TabsContent value="moderation" className="flex flex-col gap-6">
          {loading ? (
            <Card>
              <CardContent className="pt-6">
                <Skeleton className="w-full h-[350px] rounded-xl" />
              </CardContent>
            </Card>
          ) : moderation ? (
            <>
              {/* Approvals trend and admin leaderboards */}
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
                                <stop offset="5%" stopColor="oklch(0.609 0.126 135.58)" stopOpacity={0.4} />
                                <stop offset="95%" stopColor="oklch(0.609 0.126 135.58)" stopOpacity={0.0} />
                              </linearGradient>
                            </defs>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
                            <XAxis dataKey="date" tickLine={false} axisLine={false} tickMargin={8} minTickGap={32} />
                            <YAxis tickLine={false} axisLine={false} />
                            <Tooltip />
                            <Area
                              name={t.moderationTab.approvalsChartName}
                              type="monotone"
                              dataKey="value"
                              stroke="oklch(0.609 0.126 135.58)"
                              strokeWidth={2}
                              fillOpacity={1}
                              fill="url(#colorApps)"
                            />
                          </AreaChart>
                        </ResponsiveContainer>
                      </div>
                    ) : (
                      <Skeleton className="w-full h-[300px] rounded-xl" />
                    )}
                  </CardContent>
                </Card>

                {/* Rejection share + Top admins */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.moderationTab.rejectionRatio}</CardTitle>
                    <CardDescription>{t.moderationTab.rejectionDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="flex flex-col justify-center items-center h-[300px]">
                    <div className="text-center mb-4">
                      <span className="text-5xl font-extrabold tracking-tight text-rose-600 font-mono">
                        {moderation.rejectionRate.toFixed(1)}%
                      </span>
                      <p className="text-xs text-muted-foreground mt-2 font-medium">{t.moderationTab.rejectionLabel}</p>
                    </div>
                    <div className="w-full text-xs bg-muted/40 p-3 rounded-lg border">
                      <div className="flex justify-between border-b pb-2 mb-2 font-medium">
                        <span>{t.moderationTab.approvalRate}</span>
                        <span className="text-emerald-600">{(100 - moderation.rejectionRate).toFixed(1)}%</span>
                      </div>
                      <p className="text-[10px] text-muted-foreground">
                        {t.moderationTab.calculatedFrom}
                      </p>
                    </div>
                  </CardContent>
                </Card>
              </div>

              {/* Audit logs & Admin Activity table */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Admin Leaderboard */}
                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">{t.moderationTab.modActivity}</CardTitle>
                    <CardDescription>{t.moderationTab.activeModsDesc}</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[350px] overflow-y-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>{t.moderationTab.colMod}</TableHead>
                          <TableHead className="text-right">{t.moderationTab.colActions}</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {moderation.moderationActivity.map((a) => (
                          <TableRow key={a.adminId}>
                            <TableCell className="py-2">
                              <div className="flex flex-col">
                                <span className="font-semibold text-xs text-foreground">{a.adminName}</span>
                                <span className="text-[10px] text-muted-foreground">{a.adminEmail}</span>
                              </div>
                            </TableCell>
                            <TableCell className="text-right font-mono font-bold text-xs text-primary py-2">
                              {a.actionCount}
                            </TableCell>
                          </TableRow>
                        ))}
                        {!moderation.moderationActivity.length && (
                          <TableRow>
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">{t.moderationTab.noModActivity}</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>

                {/* Recent Activities Log */}
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
                              {new Date(log.createdAt).toLocaleTimeString(dateLocale, { hour: '2-digit', minute: '2-digit' })}
                            </TableCell>
                            <TableCell className="py-2 truncate max-w-[100px] font-medium">{log.userName || "Admin"}</TableCell>
                            <TableCell className="py-2">
                              <Badge className={`text-[9px] px-1 py-0 ${
                                log.activityType === "APPROVE" ? "bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20" :
                                log.activityType === "REJECT" ? "bg-rose-500/10 text-rose-500 hover:bg-rose-500/20 border-rose-500/20" :
                                "bg-muted text-muted-foreground border-muted-foreground/20"
                              }`}>
                                {log.activityType}
                              </Badge>
                            </TableCell>
                            <TableCell className="py-2 text-[11px] max-w-[200px] truncate" title={log.description}>{log.description}</TableCell>
                          </TableRow>
                        ))}
                        {!moderation.adminActivityLogs.length && (
                          <TableRow>
                            <TableCell colSpan={4} className="text-center text-muted-foreground text-xs py-4">{t.moderationTab.noAuditLogs}</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">{t.moderationTab.noRecords}</div>
          )}
        </TabsContent>
      </Tabs>

      {/* Global CSS style overrides for gorgeous printing layouts */}
      <style jsx global>{`
        @media print {
          body * {
            visibility: hidden;
          }
          #nd-sidebar, .print\\:hidden, button, header, nav, .TabsList {
            display: none !important;
          }
          div.print\\:p-0, div.print\\:p-0 * {
            visibility: visible;
          }
          div.print\\:p-0 {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            padding: 0px !important;
            margin: 0px !important;
          }
          .recharts-responsive-container {
            width: 100% !important;
            height: 350px !important;
          }
        }
      `}</style>
    </div>
  );
}
