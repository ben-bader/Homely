"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
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
  Download,
  Printer,
  RefreshCw,
  Clock,
  Shield,
  Search,
  CheckCircle,
  XCircle,
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
  Legend,
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
          "Failed to load analytics dashboard datasets. Please try again."
      );
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }, []);

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
        Time: new Date(l.createdAt).toLocaleString(),
        AdminName: l.userName,
        Action: l.activityType,
        Entity: l.entityType,
        Description: l.description,
      }));
    }

    if (!dataset.length) {
      alert("No data available for export in this category.");
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
        <h3 className="text-xl font-bold mb-2">Analytics Loading Failed</h3>
        <p className="text-muted-foreground text-center max-w-md mb-6">{error}</p>
        <Button onClick={() => fetchAllData()} className="flex items-center gap-2">
          <RefreshCw className="size-4" /> Retry Loading
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
              System Live Analytics
            </Badge>
          </div>
          <h1 className="text-3xl font-extrabold tracking-tight bg-linear-to-r from-foreground to-foreground/75 bg-clip-text">
            Centralized Platform Stats
          </h1>
          <p className="text-muted-foreground text-sm">
            Monitor real-time system metrics, registrations, property listings, and premium boost sales.
          </p>
        </div>

        {/* Global actions bar */}
        <div className="flex flex-wrap items-center gap-2 print:hidden">
          <div className="flex items-center gap-2 mr-2 bg-muted/50 border rounded-lg px-3 py-1.5 text-xs text-muted-foreground">
            <Clock className="size-3.5" />
            <span>Auto Refresh</span>
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
            Refresh
          </Button>

          <Button
            variant="outline"
            size="sm"
            onClick={handleExportCSV}
            disabled={loading}
            className="gap-2 text-xs font-semibold h-9"
          >
            <FileSpreadsheet className="size-3.5 text-emerald-600" />
            Export CSV
          </Button>

          <Button
            variant="outline"
            size="sm"
            onClick={handlePrintPDF}
            disabled={loading}
            className="gap-2 text-xs font-semibold h-9"
          >
            <Printer className="size-3.5 text-primary" />
            Print Report
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
          Last 7 Days
        </Button>
        <Button
          variant={timeRange === "30d" ? "secondary" : "ghost"}
          size="sm"
          className="text-xs py-1 h-7 font-medium px-3"
          onClick={() => setTimeRange("30d")}
        >
          Last 30 Days
        </Button>
        <Button
          variant={timeRange === "all" ? "secondary" : "ghost"}
          size="sm"
          className="text-xs py-1 h-7 font-medium px-3"
          onClick={() => setTimeRange("all")}
        >
          All Time
        </Button>
      </div>

      {/* TABS CONTAINER */}
      <Tabs defaultValue="overview" onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid grid-cols-3 md:grid-flow-col auto-cols-max gap-1 bg-muted/65 p-1 border h-auto mb-6 print:hidden">
          <TabsTrigger value="overview" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">Overview</TabsTrigger>
          <TabsTrigger value="users" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">Users</TabsTrigger>
          <TabsTrigger value="properties" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">Properties</TabsTrigger>
          <TabsTrigger value="revenue" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">Revenue</TabsTrigger>
          <TabsTrigger value="chats" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">Chats & Engagement</TabsTrigger>
          <TabsTrigger value="moderation" className="text-xs py-2 px-3 font-semibold data-[state=active]:bg-background">Moderation</TabsTrigger>
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
                      <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">Platform Users</CardDescription>
                      <Users className="size-4 text-primary" />
                    </div>
                    <CardTitle className="text-3xl font-extrabold tracking-tight">{overview.totalUsers}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <Activity className="size-3 text-emerald-600 animate-pulse" />
                      <span className="font-semibold text-foreground">{overview.activeUsersToday}</span> active on the platform today
                    </div>
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-violet-500/5 to-transparent border-violet-500/10 shadow-xs hover:shadow-md transition-all">
                  <CardHeader className="pb-2">
                    <div className="flex justify-between items-center">
                      <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">Listed Properties</CardDescription>
                      <Home className="size-4 text-violet-500" />
                    </div>
                    <CardTitle className="text-3xl font-extrabold tracking-tight">{overview.totalProperties}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    <div className="flex items-center gap-1.5">
                      <span className="inline-flex size-2 rounded-full bg-emerald-500"></span>
                      <span>{overview.totalApprovedProperties} Approved / Active</span>
                    </div>
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-amber-500/5 to-transparent border-amber-500/10 shadow-xs hover:shadow-md transition-all">
                  <CardHeader className="pb-2">
                    <div className="flex justify-between items-center">
                      <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">Premium Boost Sales</CardDescription>
                      <Zap className="size-4 text-amber-500 animate-pulse" />
                    </div>
                    <CardTitle className="text-3xl font-extrabold tracking-tight">{overview.totalBoostPurchases}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    <span className="font-semibold text-foreground">Total promotional items</span> approved for highlight
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-emerald-500/5 to-transparent border-emerald-500/10 shadow-xs hover:shadow-md transition-all">
                  <CardHeader className="pb-2">
                    <div className="flex justify-between items-center">
                      <CardDescription className="text-xs font-semibold uppercase tracking-wider text-muted-foreground/80">Platform Revenue</CardDescription>
                      <DollarSign className="size-4 text-emerald-500" />
                    </div>
                    <CardTitle className="text-3xl font-extrabold tracking-tight text-emerald-600">${overview.totalRevenue.toLocaleString()}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    Generated from <span className="font-bold text-foreground">{overview.totalBoostPurchases}</span> premium ads
                  </CardContent>
                </Card>
              </div>

              {/* Second Level Grid: Moderation, active rates */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <Card className="bg-muted/10 border-muted/50 hover:shadow-xs transition-all">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs font-semibold uppercase tracking-wider">Property Moderation</CardDescription>
                    <CardTitle className="text-2xl font-bold">{overview.totalPendingProperties}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    Properties currently pending admin validation.
                  </CardContent>
                </Card>

                <Card className="bg-muted/10 border-muted/50 hover:shadow-xs transition-all">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs font-semibold uppercase tracking-wider">Reports & Flags</CardDescription>
                    <CardTitle className="text-2xl font-bold">{overview.totalReports}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    Open tickets regarding bad listings/behavior.
                  </CardContent>
                </Card>

                <Card className="bg-muted/10 border-muted/50 hover:shadow-xs transition-all">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs font-semibold uppercase tracking-wider">Conversations Opened</CardDescription>
                    <CardTitle className="text-2xl font-bold">{overview.totalChats}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    Generating <span className="font-bold text-foreground">{overview.totalMessages}</span> message exchanges.
                  </CardContent>
                </Card>

                <Card className="bg-muted/10 border-muted/50 hover:shadow-xs transition-all">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs font-semibold uppercase tracking-wider">Monthly Active Users</CardDescription>
                    <CardTitle className="text-2xl font-bold">{overview.activeUsersThisMonth}</CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    Retention of <span className="font-bold text-foreground">{((overview.activeUsersThisMonth / Math.max(overview.totalUsers, 1)) * 100).toFixed(1)}%</span> of users.
                  </CardContent>
                </Card>
              </div>

              {/* Sparkline & Highlights */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">Quick Activity Graph</CardTitle>
                    <CardDescription>Daily platform engagement trends.</CardDescription>
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
                              name="New Registrations"
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
                    <CardTitle className="text-lg font-bold">System Status</CardTitle>
                    <CardDescription>Platform operational health.</CardDescription>
                  </CardHeader>
                  <CardContent className="flex flex-col gap-4">
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">API Connection</span>
                      <Badge className="bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20">Operational</Badge>
                    </div>
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">Database Sync</span>
                      <Badge className="bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20">Optimized</Badge>
                    </div>
                    <div className="flex items-center justify-between border-b pb-3">
                      <span className="text-xs font-semibold text-muted-foreground">Boost Engine</span>
                      <Badge className="bg-emerald-500/10 text-emerald-500 hover:bg-emerald-500/20 border-emerald-500/20">Active</Badge>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-xs font-semibold text-muted-foreground">Moderation Queue</span>
                      <Badge className={overview.totalPendingProperties > 5 ? "bg-amber-500/10 text-amber-500 border-amber-500/20" : "bg-emerald-500/10 text-emerald-500 border-emerald-500/20"}>
                        {overview.totalPendingProperties} Pending
                      </Badge>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">No overview stats found.</div>
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
                  <CardTitle className="text-lg font-bold">New User Registrations</CardTitle>
                  <CardDescription>Visualizing account creations over time.</CardDescription>
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
                            name="User Registrations"
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
                  <CardTitle className="text-lg font-bold">Active User Share</CardTitle>
                  <CardDescription>Daily vs Weekly vs Monthly active users.</CardDescription>
                </CardHeader>
                <CardContent className="flex flex-col justify-center h-[350px]">
                  {mounted && overview ? (
                    <div className="w-full h-[220px]">
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie
                            data={[
                              { name: "Active Today", value: overview.activeUsersToday },
                              { name: "Active This Week", value: overview.activeUsersThisWeek - overview.activeUsersToday },
                              { name: "Active This Month", value: overview.activeUsersThisMonth - overview.activeUsersThisWeek },
                              { name: "Inactive This Month", value: Math.max(overview.totalUsers - overview.activeUsersThisMonth, 0) },
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
                          <span>Today: {overview.activeUsersToday}</span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[1] }}></span>
                          <span>Week: {overview.activeUsersThisWeek}</span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[2] }}></span>
                          <span>Month: {overview.activeUsersThisMonth}</span>
                        </div>
                        <div className="flex items-center gap-1.5">
                          <span className="size-3 rounded-full inline-block" style={{ backgroundColor: COLORS[3] }}></span>
                          <span>Inactive: {Math.max(overview.totalUsers - overview.activeUsersThisMonth, 0)}</span>
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
            <div className="text-center p-6 text-muted-foreground">No user statistics found.</div>
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
                    <CardTitle className="text-lg font-bold">Properties by Type</CardTitle>
                    <CardDescription>Listing distribution among property categories.</CardDescription>
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
                    <CardTitle className="text-lg font-bold">Properties by Status</CardTitle>
                    <CardDescription>Ratios of active, suspended, and draft properties.</CardDescription>
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
                    <CardTitle className="text-lg font-bold">Listings Over Time</CardTitle>
                    <CardDescription>Daily creations of property ads.</CardDescription>
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
                              name="New Listings"
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
                    <CardTitle className="text-lg font-bold">Top Cities</CardTitle>
                    <CardDescription>Listings distribution by geographical city.</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[300px] overflow-y-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>City</TableHead>
                          <TableHead className="text-right">Listings</TableHead>
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
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">No city listings found</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">No property analytics found.</div>
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
                    <CardDescription className="text-xs uppercase font-semibold">Total Boost Ad Revenue</CardDescription>
                    <CardTitle className="text-4xl font-extrabold tracking-tight text-emerald-600">
                      ${revenue.boostPurchaseRevenue.toLocaleString()}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    All completed purchases of premium listings.
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-primary/5 to-transparent border-primary/10 shadow-xs">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs uppercase font-semibold">Revenue Growth MoM</CardDescription>
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
                    Month-over-month growth of promotional sales.
                  </CardContent>
                </Card>

                <Card className="bg-linear-to-b from-violet-500/5 to-transparent border-violet-500/10 shadow-xs">
                  <CardHeader className="pb-2">
                    <CardDescription className="text-xs uppercase font-semibold">Monetized Sellers</CardDescription>
                    <CardTitle className="text-4xl font-extrabold tracking-tight text-violet-600">
                      {activeSellersCount}
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="text-xs text-muted-foreground">
                    Sellers who purchased premium ad spots.
                  </CardContent>
                </Card>
              </div>

              {/* Monthly Revenue chart & top sellers */}
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">Monthly Earnings Trend</CardTitle>
                    <CardDescription>Aggregated boost purchase revenues by month.</CardDescription>
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
                            <Bar name="Revenue ($)" dataKey="amount" fill="hsl(var(--primary))" radius={[6, 6, 0, 0]} />
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
                    <CardTitle className="text-lg font-bold">Premium Sellers</CardTitle>
                    <CardDescription>Top revenue contributing agents and agencies.</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[320px] overflow-y-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Agent</TableHead>
                          <TableHead className="text-right">Revenue</TableHead>
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
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">No revenue transactions recorded</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">No financial records found.</div>
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
                    <CardTitle className="text-lg font-bold">Messages Activity</CardTitle>
                    <CardDescription>Frequency of chat messages sent over time.</CardDescription>
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
                              name="Messages Sent"
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
                    <CardTitle className="text-lg font-bold">Favorites Action</CardTitle>
                    <CardDescription>Daily addition of listings to users' favorites.</CardDescription>
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
                              name="New Favorites"
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
                    <CardTitle className="text-lg font-bold">Most Viewed Properties</CardTitle>
                    <CardDescription>Property listings with maximum viewer traffic.</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Property Title</TableHead>
                          <TableHead className="text-right">Total Views</TableHead>
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
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">No view traffic recorded</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">Most Favorited Properties</CardTitle>
                    <CardDescription>Highly desired properties added to user wishlists.</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Property Title</TableHead>
                          <TableHead className="text-right">Favorites Count</TableHead>
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
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">No wishlist records found</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">No engagement stats found.</div>
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
                    <CardTitle className="text-lg font-bold">Approvals Timeline</CardTitle>
                    <CardDescription>Listed properties approved by administrative moderators over time.</CardDescription>
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
                              name="Approvals"
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
                    <CardTitle className="text-lg font-bold">Rejection Ratio</CardTitle>
                    <CardDescription>Percentage of listing rejections relative to total actions.</CardDescription>
                  </CardHeader>
                  <CardContent className="flex flex-col justify-center items-center h-[300px]">
                    <div className="text-center mb-4">
                      <span className="text-5xl font-extrabold tracking-tight text-rose-600 font-mono">
                        {moderation.rejectionRate.toFixed(1)}%
                      </span>
                      <p className="text-xs text-muted-foreground mt-2 font-medium">Platform Rejection Ratio</p>
                    </div>
                    <div className="w-full text-xs bg-muted/40 p-3 rounded-lg border">
                      <div className="flex justify-between border-b pb-2 mb-2 font-medium">
                        <span>Approval Rate</span>
                        <span className="text-emerald-600">{(100 - moderation.rejectionRate).toFixed(1)}%</span>
                      </div>
                      <p className="text-[10px] text-muted-foreground">
                        Calculated dynamically from total administrative <strong>Approve</strong> and <strong>Reject</strong> operations.
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
                    <CardTitle className="text-lg font-bold">Mod Activity</CardTitle>
                    <CardDescription>Most active administrative moderators.</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[350px] overflow-y-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Administrator</TableHead>
                          <TableHead className="text-right">Actions</TableHead>
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
                            <TableCell colSpan={2} className="text-center text-muted-foreground text-xs py-4">No moderator activity logged</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>

                {/* Recent Activities Log */}
                <Card className="col-span-2">
                  <CardHeader>
                    <CardTitle className="text-lg font-bold">Administrative Logs</CardTitle>
                    <CardDescription>Recent audit logs of administrative moderations.</CardDescription>
                  </CardHeader>
                  <CardContent className="h-[350px] overflow-y-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead className="w-[100px]">Time</TableHead>
                          <TableHead className="w-[120px]">Admin</TableHead>
                          <TableHead className="w-[100px]">Operation</TableHead>
                          <TableHead>Details</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {moderation.adminActivityLogs.slice(0, 15).map((log) => (
                          <TableRow key={log.id} className="text-xs">
                            <TableCell className="py-2 whitespace-nowrap text-muted-foreground text-[10px]">
                              {new Date(log.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
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
                            <TableCell colSpan={4} className="text-center text-muted-foreground text-xs py-4">No audit logs recorded</TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </CardContent>
                </Card>
              </div>
            </>
          ) : (
            <div className="text-center p-6 text-muted-foreground">No moderation records found.</div>
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
