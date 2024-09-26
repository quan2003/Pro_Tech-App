import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class YearScreen extends StatefulWidget {
  const YearScreen({Key? key}) : super(key: key);

  @override
  _YearScreenState createState() => _YearScreenState();
}

class _YearScreenState extends State<YearScreen> {
  final Map<String, IconData> iconMap = {
    'directions_walk': Icons.directions_walk,
    'local_fire_department': Icons.local_fire_department,
    'straighten': Icons.square_foot,
    'timer': Icons.timer,
  };

  Map<String, int> monthlyData = {};
  int totalSteps = 0;
  double averageSteps = 0;
  double totalCalories = 0;
  double totalDistance = 0;
  int totalMinutes = 0;
  DateTime? startOfYear;
  DateTime? endOfYear;

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    final random = Random();
    startOfYear = DateTime(2024, 1, 1);
    endOfYear = DateTime(2024, 12, 31);

    for (int month = 1; month <= 12; month++) {
      String monthKey = DateFormat('yyyy-MM').format(DateTime(2024, month, 1));
      int steps = random.nextInt(300000) +
          100000; // Random steps between 100,000 and 400,000
      monthlyData[monthKey] = steps;
      totalSteps += steps;
    }

    averageSteps = totalSteps / 12;
    totalCalories = totalSteps * 0.04; // Assuming 0.04 calories per step
    totalDistance = totalSteps * 0.0008; // Assuming 0.0008 km per step
    totalMinutes =
        (totalSteps * 0.01).round(); // Assuming 0.01 minutes per step

    setState(() {}); // Update the UI with the new data
  }

  Widget _buildYearChart() {
    double maxY = monthlyData.values.reduce(max).toDouble();
    List<BarChartGroupData> barGroups = [];

    for (int i = 1; i <= 12; i++) {
      String monthKey =
          DateFormat('yyyy-MM').format(DateTime(startOfYear!.year, i, 1));
      double steps = monthlyData[monthKey]?.toDouble() ?? 0;

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: steps,
            gradient: _barsGradient,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ));
    }

    return Container(
      height: 300,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBorder: BorderSide(color: Colors.blueAccent, width: 1),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String monthName = DateFormat('MMMM')
                    .format(DateTime(startOfYear!.year, group.x.toInt(), 1));
                return BarTooltipItem(
                  '$monthName\n',
                  const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${NumberFormat('#,###').format(rod.toY.round())} bước',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = [
                    'T1',
                    'T2',
                    'T3',
                    'T4',
                    'T5',
                    'T6',
                    'T7',
                    'T8',
                    'T9',
                    'T10',
                    'T11',
                    'T12'
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[value.toInt() - 1],
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: maxY / 5,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade900,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // appBar: AppBar(
    //   title: Text('Bước chân'),
    //   backgroundColor: Colors.white,
    //   foregroundColor: Colors.black,
    //   elevation: 0,
    // ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TỔNG HÀNG NĂM',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Năm ${startOfYear?.year ?? ''}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${NumberFormat('#,###').format(totalSteps)} bước',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Trung bình ${NumberFormat('#,###').format(averageSteps.round())}',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_upward, color: Colors.green, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildYearChart(),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildStatisticsSummary(),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildStatisticsSummary() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildStatItem('directions_walk', NumberFormat('#,###').format(totalSteps), 'bước'),
      _buildStatItem('local_fire_department', NumberFormat('#,###').format(totalCalories.round()), 'kcal'),
      _buildStatItem('straighten', totalDistance.toStringAsFixed(1), 'km'),
      _buildStatItem('timer', NumberFormat('#,###').format(totalMinutes), 'phút'),
    ],
  );
}
Widget _buildStatItem(String iconName, String value, String label) {
  return Expanded(
    child: Column(
      children: [
        Icon(iconMap[iconName] ?? Icons.error, size: 24, color: Colors.blue),
        SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      ],
    ),
  );
  }
}
