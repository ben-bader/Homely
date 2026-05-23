import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/theme/app_colors.dart';
import 'package:homely/data/models/analytics/analytics_point_model.dart';
import 'package:homely/data/models/analytics/seller_dashboard_model.dart';
import 'package:homely/data/models/analytics/top_property_model.dart';
import 'package:homely/ui/providers/seller_analytics_providers.dart';
import 'package:shimmer/shimmer.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  static const routeName = '/seller-dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(sellerAnalyticsProvider);
    final viewsAsync = ref.watch(sellerAnalyticsViewsOverTimeProvider);
    final messagesAsync = ref.watch(sellerAnalyticsMessagesOverTimeProvider);
    final visitsAsync = ref.watch(sellerAnalyticsVisitsOverTimeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh analytics',
            onPressed: () {
              ref.invalidate(sellerAnalyticsProvider);
              ref.invalidate(sellerAnalyticsViewsOverTimeProvider);
              ref.invalidate(sellerAnalyticsMessagesOverTimeProvider);
              ref.invalidate(sellerAnalyticsVisitsOverTimeProvider);
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => _buildLoadingBody(context),
        error: (error, stack) => _buildErrorBody(context, ref, error.toString()),
        data: (dashboard) => _buildContent(
          context,
          ref,
          dashboard,
          viewsAsync,
          messagesAsync,
          visitsAsync,
        ),
      ),
    );
  }

  Widget _buildLoadingBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSkeleton(),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                6,
                (_) => SizedBox(
                  width: 160,
                  child: _buildKpiSkeletonCard(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildChartSkeleton(),
            const SizedBox(height: 16),
            _buildChartSkeleton(),
            const SizedBox(height: 16),
            _buildChartSkeleton(),
            const SizedBox(height: 24),
            _buildListSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.subtleBackground,
      highlightColor: AppColors.background,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 28,
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.subtleBackground,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildKpiSkeletonCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 12),
      child: Shimmer.fromColors(
        baseColor: AppColors.subtleBackground,
        highlightColor: AppColors.background,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.subtleBackground,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.subtleBackground,
      highlightColor: AppColors.background,
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          color: AppColors.subtleBackground,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: AppColors.subtleBackground,
            highlightColor: AppColors.background,
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.subtleBackground,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 52),
            const SizedBox(height: 16),
            Text(
              'Unable to load analytics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () {
                ref.invalidate(sellerAnalyticsProvider);
                ref.invalidate(sellerAnalyticsViewsOverTimeProvider);
                ref.invalidate(sellerAnalyticsMessagesOverTimeProvider);
                ref.invalidate(sellerAnalyticsVisitsOverTimeProvider);
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SellerDashboardModel dashboard,
    AsyncValue<List<AnalyticsPointModel>> viewsAsync,
    AsyncValue<List<AnalyticsPointModel>> messagesAsync,
    AsyncValue<List<AnalyticsPointModel>> visitsAsync,
  ) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1000 ? 4 : width >= 720 ? 3 : 2;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(sellerAnalyticsProvider);
        ref.invalidate(sellerAnalyticsViewsOverTimeProvider);
        ref.invalidate(sellerAnalyticsMessagesOverTimeProvider);
        ref.invalidate(sellerAnalyticsVisitsOverTimeProvider);
      },
      color: AppColors.primary,
      backgroundColor: AppColors.background,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Performance overview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate(
                [
                  _buildKpiCard(
                    label: 'Total listings',
                    value: dashboard.totalListings.toString(),
                    accent: AppColors.primary,
                  ),
                  _buildKpiCard(
                    label: 'Active listings',
                    value: dashboard.activeListings.toString(),
                    accent: AppColors.success,
                  ),
                  _buildKpiCard(
                    label: 'Inactive listings',
                    value: dashboard.inactiveListings.toString(),
                    accent: AppColors.warning,
                  ),
                  _buildKpiCard(
                    label: 'Views',
                    value: _formatCompactNumber(dashboard.totalViews),
                    accent: AppColors.info,
                  ),
                  _buildKpiCard(
                    label: 'Messages',
                    value: _formatCompactNumber(dashboard.totalMessages),
                    accent: AppColors.primaryLight,
                  ),
                  _buildKpiCard(
                    label: 'Conversion rate',
                    value: '${dashboard.conversionRate.toStringAsFixed(1)}%',
                    accent: AppColors.success,
                  ),
                ],
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 24)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Views over time'),
                  const SizedBox(height: 12),
                  _buildChartCard(context, viewsAsync, 'Views', AppColors.success),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Messages over time'),
                  const SizedBox(height: 12),
                  _buildChartCard(context, messagesAsync, 'Messages', AppColors.info),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Visits over time'),
                  const SizedBox(height: 12),
                  _buildChartCard(context, visitsAsync, 'Visits', AppColors.warning),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Top performing properties'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (dashboard.topProperties.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    'No top properties are available yet. Create more listings or wait for performance data to appear.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = dashboard.topProperties[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPropertyCard(context, item),
                    );
                  },
                  childCount: dashboard.topProperties.length,
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.primary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    AsyncValue<List<AnalyticsPointModel>> analytics,
    String label,
    Color accent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: analytics.when(
        loading: () => SizedBox(
          height: 220,
          child: Center(
            child: CircularProgressIndicator(color: accent),
          ),
        ),
        error: (_, __) => SizedBox(
          height: 220,
          child: Center(
            child: Text(
              'Unable to load $label chart',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ),
        data: (points) {
          if (points.isEmpty) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'No $label data available yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.borderLight.withOpacity(0.7),
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: max(1, points.length / 5).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        final point = points[index];
                        return Text(
                          _formatChartLabel(point.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: 0,
                maxY: max(1, points.map((e) => e.value).reduce(max)),
                lineBarsData: [
                  LineChartBarData(
                    spots: points
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
                        .toList(),
                    isCurved: true,
                    color: accent,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: accent.withOpacity(0.18),
                    ),
                  )
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spots) => AppColors.primary.withOpacity(0.9),
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final index = spot.x.toInt();
                        final point = points[index];
                        return LineTooltipItem(
                          '${_formatChartTooltip(point.date)}\n${spot.y.toInt()} $label',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, TopPropertyModel property) {
    final trendPositive = property.views >= property.messages;
    final trendColor = trendPositive ? AppColors.success : AppColors.error;
    final trendIcon = trendPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(trendIcon, size: 18, color: trendColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPropertyStat('Views', property.views.toString(), AppColors.success),
              _buildPropertyStat('Msgs', property.messages.toString(), AppColors.info),
              _buildPropertyStat('Favs', property.favorites.toString(), AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatChartLabel(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _formatChartTooltip(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCompactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}
