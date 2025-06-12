import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:home_service_admin/routes/navigation_service.dart';
import 'package:home_service_admin/themes/app_assets.dart';
import 'package:home_service_admin/themes/app_colors.dart';
import 'package:home_service_admin/themes/style_text.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NavigationService _navigationService = NavigationService();
  int selectedIndex = 0;
  String selectedMonth = 'Feb 2023';

  final List<String> months = [
    'Jan 2023',
    'Feb 2023',
    'Mar 2023',
    'Apr 2023',
    'May 2023',
    'Jun 2023',
    'Jul 2023',
    'Aug 2023'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F4FA),
      body: Row(
        children: [
          // Main Content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedMonth,
                          dropdownColor: Colors.blue,
                          underline: SizedBox(),
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Colors.white),
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          items: months.map((String month) {
                            return DropdownMenuItem<String>(
                              value: month,
                              child: Text(month),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard('178+', 'Save Products',
                              Colors.purple, AppAssetsIcons.heartFullIc)),
                      SizedBox(width: 16),
                      Expanded(
                          child: _buildStatCard('20+', 'Stock Products',
                              Colors.green, AppAssetsIcons.stockIc)),
                      SizedBox(width: 16),
                      Expanded(
                          child: _buildStatCard('190+', 'Sales Products',
                              Colors.pink, AppAssetsIcons.salesIc)),
                      SizedBox(width: 16),
                      Expanded(
                          child: _buildStatCard('12+', 'Job Application',
                              Colors.blue, AppAssetsIcons.jobAppIc)),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Charts Row
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildReportsChart(),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _buildAnalyticsChart(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Tables Row
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildRecentOrders(),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: _buildTopSellingProducts(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, String icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(icon),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
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

  Widget _buildReportsChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reports',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(),
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.neutral,
                            ));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          '10am',
                          '11am',
                          '12am',
                          '01am',
                          '02am',
                          '03am',
                          '04am',
                          '05am',
                          '06am',
                          '07am'
                        ];
                        if (value.toInt() < titles.length) {
                          return Text(
                            titles[value.toInt()],
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.textLight,
                              fontSize: 10,
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 40),
                      FlSpot(1, 50),
                      FlSpot(2, 35),
                      FlSpot(3, 60),
                      FlSpot(4, 45),
                      FlSpot(5, 70),
                      FlSpot(6, 55),
                      FlSpot(7, 65),
                      FlSpot(8, 80),
                      FlSpot(9, 75),
                    ],
                    isCurved: true,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withValues(alpha: 0.3),
                          Colors.pink.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Sales',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                Text('2,678',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsChart() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 80,
                            color: Colors.blue,
                            radius: 30,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 15,
                            color: Colors.green,
                            radius: 30,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 5,
                            color: Colors.pink,
                            radius: 30,
                            showTitle: false,
                          ),
                        ],
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(Colors.blue, 'Sale'),
              _buildLegendItem(Colors.green, 'Distribute'),
              _buildLegendItem(Colors.pink, 'Return'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Recent Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                horizontalMargin: 0,
                columns: [
                  DataColumn(
                      label:
                          Text('Tracking no', style: TextStyle(fontSize: 12))),
                  DataColumn(
                      label:
                          Text('Product Name', style: TextStyle(fontSize: 12))),
                  DataColumn(
                      label: Text('Price', style: TextStyle(fontSize: 12))),
                  DataColumn(
                      label:
                          Text('Total Order', style: TextStyle(fontSize: 12))),
                  DataColumn(
                      label:
                          Text('Total Amount', style: TextStyle(fontSize: 12))),
                ],
                rows: [
                  _buildOrderRow(
                      '#876364', 'Camera Lens', '\$178', '325', '\$1,46,660'),
                  _buildOrderRow(
                      '#876368', 'Black Sleep Dress', '\$14', '53', '\$40,520'),
                  _buildOrderRow(
                      '#876412', 'Organ Oil', '\$21', '78', '\$3,46,676'),
                  _buildOrderRow(
                      '#876501', 'EAU De Perfume', '\$32', '182', '\$3,46,676'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildOrderRow(String tracking, String product, String price,
      String order, String amount) {
    return DataRow(
      cells: [
        DataCell(Text(tracking, style: TextStyle(fontSize: 12))),
        DataCell(Text(product, style: TextStyle(fontSize: 12))),
        DataCell(Text(price, style: TextStyle(fontSize: 12))),
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(order,
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
        ),
        DataCell(Text(amount, style: TextStyle(fontSize: 12))),
      ],
    );
  }

  Widget _buildTopSellingProducts() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildProductItem(
                  'NIKE Shoes Black Pattern',
                  '\$87',
                  4.5,
                  Colors.blue,
                ),
                SizedBox(height: 16),
                _buildProductItem(
                  'iPhone 12',
                  '\$987',
                  3.5,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
      String name, String price, double rating, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 12,
                        color:
                            index < rating ? Colors.orange : Colors.grey[300],
                      );
                    }),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
