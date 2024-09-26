import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class YearScreen extends StatefulWidget {
  const YearScreen({Key? key}) : super(key: key);

  @override
  _YearScreenState createState() => _YearScreenState();
}

class _YearScreenState extends State<YearScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, int> monthlyData = {};
  int totalSteps = 0;
  double averageSteps = 0;
  double totalCalories = 0;
  double totalDistance = 0;
  int totalMinutes = 0;
  int stepGoal = 60000; // Giả sử mục tiêu hàng tháng là 60,000 bước
  DateTime? startOfYear;
  DateTime? endOfYear;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirebase();
  }

  Future<void> _loadDataFromFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      DateTime now = DateTime.now();
      startOfYear = DateTime(now.year, 1, 1);
      endOfYear = DateTime(now.year, 12, 31);

      String startDate = DateFormat('yyyy-M-d').format(startOfYear!);
      String endDate = DateFormat('yyyy-M-d').format(endOfYear!);

      var collectionRef = _firestore
          .collection('activity_data')
          .doc(user.uid)
          .collection('daily_data');

      QuerySnapshot querySnapshot = await collectionRef
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDate)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endDate)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No data found for this year.');
      } else {
        totalSteps = 0;
        totalCalories = 0;
        totalDistance = 0;
        totalMinutes = 0;

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
          DateTime date = DateFormat('yyyy-M-d').parse(doc.id);
          String monthKey = DateFormat('yyyy-MM').format(date);

          int steps = (docData['steps'] ?? 0).toInt();
          monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + steps;

          totalSteps += steps;
          totalCalories += (docData['calories'] ?? 0).toDouble();
          totalDistance += (docData['distance'] ?? 0).toDouble();
          int minutes = (docData['minutes'] ?? 0).toInt();
          totalMinutes += minutes;
        }

        averageSteps = totalSteps / 365;

        print('Total Steps: $totalSteps');
        print('Average Steps: $averageSteps');
        print('Total Calories: $totalCalories');
        print('Total Distance: $totalDistance');
        print('Total Minutes: $totalMinutes');
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildYearContent(),
    );
  }

  Widget _buildYearContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG HÀNG NĂM',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Năm ${startOfYear?.year ?? ''}',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$totalSteps bước',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Text(
                      'Trung bình ${averageSteps.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_upward,
                        color: Colors.green, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildYearChart(),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('bước', '$totalSteps', Icons.directions_walk),
              _buildStatItem('kcal', '${totalCalories.toStringAsFixed(0)}',
                  Icons.local_fire_department),
              _buildStatItem('km', '${totalDistance.toStringAsFixed(1)}',
                  Icons.directions),
              _buildStatItem('phút', '$totalMinutes', Icons.timer),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildYearChart() {
  List<FlSpot> spots = [];
  double maxY = 0;

  for (int i = 1; i <= 12; i++) {
    String monthKey = DateFormat('yyyy-MM').format(DateTime(startOfYear!.year, i, 1));
    double steps = (monthlyData[monthKey] ?? 0).toDouble();
    if (steps > 0) {
      spots.add(FlSpot(i.toDouble(), steps));
      if (steps > maxY) maxY = steps;
    }
  }

  return SizedBox(
    height: 200,
    child: LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 4,
          verticalInterval: 1,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: 12,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.blue,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 6,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: Colors.blue,
              ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
      ),
    ),
  );
}


  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 38, color: Colors.blue),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
