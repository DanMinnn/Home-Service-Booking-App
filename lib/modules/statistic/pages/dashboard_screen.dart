import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/statistic/bloc/dashboard_bloc.dart';
import 'package:home_service_admin/modules/statistic/bloc/dashboard_event.dart';
import 'package:home_service_admin/modules/statistic/bloc/dashboard_state.dart';
import 'package:home_service_admin/modules/statistic/models/dashboard_models.dart';
import 'package:home_service_admin/modules/statistic/repo/dashboard_repo.dart';
import 'package:home_service_admin/themes/app_colors.dart';
import 'package:home_service_admin/themes/style_text.dart';
import 'package:intl/intl.dart';

import '../../../themes/app_assets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  String selectedMonth = DateFormat('MMM yyyy').format(DateTime.now());
  late DashboardBloc _dashboardBloc;
  final List<Color> statusColors = [
    Colors.red,
    Colors.blue,
    Colors.amber,
    Colors.purple,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _dashboardBloc = DashboardBloc(DashboardRepo());
    _loadDashboardData();
  }

  void _loadDashboardData() {
    _dashboardBloc.add(DashboardLoadEvent());
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: BlocProvider.value(
        value: _dashboardBloc,
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Color(0xFF3A36DB),
              ));
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(state.dashboardData);
            } else if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${(state).message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardData dashboardData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Home Service Dashboard",
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loadDashboardData,
                  icon: Icon(Icons.refresh, color: AppColors.neutral),
                  label: const Text("Refresh Data"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Cards Row 1
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildStatCard(
                  "${dashboardData.completedTasks.totalCompletedTasks}",
                  'Total Completed Tasks',
                  Colors.green,
                  Icons.task_alt,
                ),
                _buildStatCard(
                  "${dashboardData.completedTasks.completedTasksToday}",
                  'Completed Today',
                  Colors.blue,
                  Icons.today,
                ),
                _buildStatCard(
                  "${dashboardData.completedTasks.completedTasksThisWeek}",
                  'Completed This Week',
                  Colors.purple,
                  Icons.date_range,
                ),
                _buildStatCard(
                  "${dashboardData.completedTasks.completedTasksThisMonth}",
                  'Completed This Month',
                  Colors.orange,
                  Icons.calendar_month,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stats Cards Row 2
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildStatCard(
                  "${dashboardData.pendingBookingsCount}",
                  'Pending Bookings',
                  Colors.amber,
                  Icons.pending_actions,
                ),
                _buildStatCard(
                  "${dashboardData.userRegistrations.totalTaskers}",
                  'Total Taskers',
                  Colors.teal,
                  Icons.engineering,
                ),
                _buildStatCard(
                  "${dashboardData.userRegistrations.totalClients}",
                  'Total Clients',
                  Colors.indigo,
                  Icons.person,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Revenue Section Title
            Text(
              "Revenue Statistics",
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Revenue Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildRevenueCard(
                  _formatCurrency(dashboardData.revenueServices?.totalRevenueSum ?? 0),
                  'Total Revenue',
                  AppColors.primary,
                  Icons.account_balance_wallet,
                  dashboardData.revenueServices?.totalRevenues ?? [],
                ),
                _buildRevenueCard(
                  _formatCurrency(dashboardData.revenueServices?.totalRevenueTodaySum ?? 0),
                  'Revenue Today',
                  AppColors.secondary,
                  Icons.today,
                  dashboardData.revenueServices?.totalRevenuesToday ?? [],
                ),
                _buildRevenueCard(
                  _formatCurrency(dashboardData.revenueServices?.totalRevenueThisWeekSum ?? 0),
                  'Revenue This Week',
                  AppColors.accent,
                  Icons.date_range,
                  dashboardData.revenueServices?.totalRevenuesThisWeek ?? [],
                ),
                _buildRevenueCard(
                  _formatCurrency(dashboardData.revenueServices?.totalRevenueThisMonthSum ?? 0),
                  'Revenue This Month',
                  AppColors.primary,
                  Icons.calendar_month,
                  dashboardData.revenueServices?.totalRevenuesThisMonth ?? [],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Service Revenue Details
            dashboardData.revenueServices != null &&
                    dashboardData.revenueServices!.totalRevenues.isNotEmpty
                ? _buildServiceRevenueList(dashboardData.revenueServices!)
                : const SizedBox(),

            const SizedBox(height: 24),

            // Charts Row
            SizedBox(
              height: 400,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Trend Chart
                  Expanded(
                    flex: 2,
                    child: _buildBookingTrendChart(dashboardData),
                  ),
                  const SizedBox(width: 24),
                  // Booking Status Distribution
                  Expanded(
                    child: _buildBookingStatusChart(dashboardData),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Services & Recent Bookings
            SizedBox(
              height: 400,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Services
                  Expanded(
                    child: _buildTopServicesCard(dashboardData),
                  ),
                  const SizedBox(width: 24),
                  // Recent Orders
                  Expanded(
                    flex: 2,
                    child: _buildRecentBookings(dashboardData),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Top Taskers
            SizedBox(
              height: 280,
              child: _buildTopTaskersCard(dashboardData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, Color color, IconData iconData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: color),
              ),
              const Spacer(),
              Icon(
                value == '0' ? Icons.trending_flat : Icons.trending_up,
                color: value == '0' ? Colors.grey : Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // New method to build revenue cards
  Widget _buildRevenueCard(
    String value,
    String label,
    Color color,
    IconData iconData,
    List<ServiceRevenue> revenueDetails,
  ) {
    return InkWell(
      onTap: () {
        if (revenueDetails.isNotEmpty) {
          _showRevenueDetailsDialog(label, revenueDetails);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData, color: color),
                ),
                const Spacer(),
                Icon(
                  value == '₫0' ? Icons.trending_flat : Icons.trending_up,
                  color: value == '₫0' ? Colors.grey : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to show revenue details in a dialog
  void _showRevenueDetailsDialog(String title, List<ServiceRevenue> revenues) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: revenues.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final revenue = revenues[index];
              return ListTile(
                title: Text(revenue.serviceName),
                subtitle: Text('${revenue.categoryName} | ${revenue.bookingCount} bookings'),
                trailing: Text(
                  _formatCurrency(revenue.totalRevenue),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // New method to build a revenue list section
  Widget _buildServiceRevenueList(RevenueServices revenueServices) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Revenue Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                children: [
                  _tableHeader('#'),
                  _tableHeader('Service'),
                  _tableHeader('Bookings'),
                  _tableHeader('Revenue'),
                ],
              ),
              ...revenueServices.totalRevenues.asMap().entries.map(
                (entry) => TableRow(
                  decoration: BoxDecoration(
                    color: entry.key.isEven ? Colors.white : Colors.grey[50],
                  ),
                  children: [
                    _tableCell('${entry.key + 1}'),
                    _tableCell('${entry.value.serviceName}\n${entry.value.categoryName}', isTitle: true),
                    _tableCell('${entry.value.bookingCount}'),
                    _tableCell(_formatCurrency(entry.value.totalRevenue), isRevenue: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text, {bool isTitle = false, bool isRevenue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isTitle || isRevenue ? FontWeight.w600 : FontWeight.normal,
          color: isRevenue ? AppColors.primary : null,
        ),
        textAlign: isTitle ? TextAlign.left : TextAlign.center,
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _buildBookingTrendChart(DashboardData dashboardData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Booking Trends',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Daily View',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: dashboardData.bookingTrends.length < 2
                ? const Center(child: Text("Not enough data for chart"))
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: _leftTitleWidgets,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() <
                                      dashboardData.bookingTrends.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    dashboardData.bookingTrends[value.toInt()]
                                        .formattedDate,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: AppColors.textLight,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getBookingTrendSpots(dashboardData),
                          isCurved: false,
                          barWidth: 3,
                          color: AppColors.secondary,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.secondary.withValues(alpha: 0.3),
                                AppColors.primary.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return Text(
      '${value.toInt()}',
      style: AppTextStyles.titleSmall.copyWith(
        color: AppColors.neutral,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }

  List<FlSpot> _getBookingTrendSpots(DashboardData dashboardData) {
    List<FlSpot> spots = [];
    for (int i = 0; i < dashboardData.bookingTrends.length; i++) {
      spots.add(FlSpot(
          i.toDouble(), dashboardData.bookingTrends[i].count.toDouble()));
    }
    return spots;
  }

  Widget _buildBookingStatusChart(DashboardData dashboardData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Booking Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.info_outline,
                        size: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: dashboardData.bookingStatusDistribution.isEmpty
                ? const Center(child: Text('No status data available'))
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _getBookingStatusSections(dashboardData),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(
              dashboardData.bookingStatusDistribution.length,
              (index) => _buildLegendItem(
                statusColors[index % statusColors.length],
                _formatStatusName(
                    dashboardData.bookingStatusDistribution[index].status),
                dashboardData.bookingStatusDistribution[index].count.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatusName(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  List<PieChartSectionData> _getBookingStatusSections(
      DashboardData dashboardData) {
    // Calculate total for percentages
    final total = dashboardData.bookingStatusDistribution
        .fold(0, (sum, item) => sum + item.count);

    return List.generate(
      dashboardData.bookingStatusDistribution.length,
      (i) {
        final data = dashboardData.bookingStatusDistribution[i];
        final percent = total > 0 ? (data.count / total) * 100 : 0.0;
        return PieChartSectionData(
          color: statusColors[i % statusColors.length],
          value: data.count.toDouble(),
          title: '${percent.toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTopServicesCard(DashboardData dashboardData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: dashboardData.topServices.isEmpty
                ? const Center(child: Text('No top services data'))
                : ListView.separated(
                    itemCount: dashboardData.topServices.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final service = dashboardData.topServices[index];
                      return _buildTopServiceItem(
                        service.serviceName,
                        service.categoryName,
                        service.bookingCount,
                        index + 1,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopServiceItem(
      String name, String category, int bookingCount, int rank) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: rank <= 3
                ? [Colors.amber, Colors.grey, Colors.brown][rank - 1]
                : Colors.blue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rank <= 3 ? Colors.white : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                category,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$bookingCount bookings',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentBookings(DashboardData dashboardData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: dashboardData.recentBookings.isEmpty
                ? const Center(child: Text('No recent bookings'))
                : ListView.separated(
                    itemCount: dashboardData.recentBookings.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final booking = dashboardData.recentBookings[index];
                      return _buildBookingItem(booking);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(RecentBooking booking) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tasker Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              image: booking.taskerImage != null
                  ? DecorationImage(
                      image: NetworkImage(booking.taskerImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: booking.taskerImage == null
                ? Image.asset(AppAssetsIcons.documentIc)
                : null,
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _buildStatusTag(booking.status),
                  ],
                ),
                const SizedBox(height: 5),

                // Customer Details
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.username} | ${booking.phoneNumber}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Tasker Details
                Row(
                  children: [
                    const Icon(Icons.engineering, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.taskerName} | ${booking.taskerPhone}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Bottom Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Scheduled Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          booking.formattedScheduledTime,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    // Price and Payment Status
                    Row(
                      children: [
                        Text(
                          NumberFormat.currency(
                            symbol: '₫',
                            decimalDigits: 0,
                          ).format(booking.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentTag(booking.paymentStatus),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.amber;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'assigned':
        color = Colors.blue;
        break;
      case 'in_progress':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatStatusName(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentTag(String status) {
    final bool isPaid = status.toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatStatusName(status),
        style: TextStyle(
          color: isPaid ? Colors.green : Colors.grey[700],
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTopTaskersCard(DashboardData dashboardData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Taskers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: dashboardData.topTaskers.isEmpty
                ? const Center(child: Text('No top taskers data available'))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dashboardData.topTaskers.length,
                    itemBuilder: (context, index) {
                      final tasker = dashboardData.topTaskers[index];
                      return _buildTaskerCard(tasker, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskerCard(TopTasker tasker, int rank) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              // Tasker Image
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  image: tasker.profileImage != null
                      ? DecorationImage(
                          image: NetworkImage(tasker.profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(
                    color: rank <= 3
                        ? [Colors.amber, Colors.grey, Colors.brown][rank - 1]
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: tasker.profileImage == null
                    ? Icon(Icons.person, size: 40, color: Colors.grey[500])
                    : null,
              ),

              // Rank Badge
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? [Colors.amber, Colors.grey, Colors.brown][rank - 1]
                      : Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Tasker Name
          Text(
            tasker.taskerName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),

          // Reputation Score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                tasker.reputationScore.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Completed Tasks
          Text(
            '${tasker.completedTasksCount} tasks completed',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
