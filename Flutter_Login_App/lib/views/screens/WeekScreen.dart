import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  _WeekScreenState createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<int> stepsPerDay = List.filled(7, 0);
  List<double> caloriesPerDay = List.filled(7, 0);
  List<double> distancePerDay = List.filled(7, 0);
  List<int> minutesPerDay = List.filled(7, 0);
  int totalSteps = 0;
  double averageSteps = 0;
  double totalCalories = 0;
  double totalDistance = 0;
  int totalMinutes = 0;
  double? lastWeekAverageSteps;
  DateTime? startOfWeek;
  DateTime? endOfWeek;

  @override
  void initState() {
    super.initState();
    totalSteps = 0;
    averageSteps = 0;
    totalCalories = 0;
    totalDistance = 0;
    totalMinutes = 0;
    _initializeData();
  }

  Future<void> _initializeData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await checkFirestoreStructure(user.uid);
      await _loadDataFromFirebase(user.uid);
      await _loadLastWeekDataFromFirebase(user.uid);
      setState(() {});
    } else {
      print("Không có người dùng đang đăng nhập.");
      // Xử lý trường hợp không có người dùng đăng nhập ở đây
      // Ví dụ: Chuyển hướng đến màn hình đăng nhập
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  Future<void> _loadLastWeekDataFromFirebase(String userId) async {
    DateTime now = DateTime.now();
    DateTime startOfLastWeek = now.subtract(Duration(days: now.weekday + 6));
    DateTime endOfLastWeek = startOfLastWeek.add(const Duration(days: 6));

    List<int> lastWeekSteps = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startOfLastWeek.add(Duration(days: i));
      String dateKey =
          "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

      DocumentSnapshot snapshot = await _firestore
          .collection('activity_data')
          .doc(userId)
          .collection('daily_data')
          .doc(dateKey)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        lastWeekSteps[i] = data['steps'] ?? 0;
      }
    }

    int lastWeekTotalSteps = lastWeekSteps.reduce((a, b) => a + b);
    lastWeekAverageSteps = lastWeekTotalSteps / 7;
  }

  Future<void> _loadDataFromFirebase(String userId) async {
    DateTime now = DateTime.now();
    startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    endOfWeek = startOfWeek!.add(const Duration(days: 6));

    print(
        "Đang tải dữ liệu cho tuần: ${startOfWeek!.toString()} đến ${endOfWeek!.toString()}");

    DocumentReference userDocRef =
        _firestore.collection('activity_data').doc(userId);

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startOfWeek!.add(Duration(days: i));
      String dateKey =
          "${currentDate.year}-${currentDate.month}-${currentDate.day}";

      print("Truy xuất dữ liệu cho ngày: $dateKey");

      try {
        DocumentSnapshot snapshot =
            await userDocRef.collection('daily_data').doc(dateKey).get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          print("Dữ liệu tìm thấy cho $dateKey: $data");

          stepsPerDay[i] = data['steps'] ?? 0;
          caloriesPerDay[i] = (data['calories'] ?? 0).toDouble();
          distancePerDay[i] = (data['distance'] ?? 0).toDouble();
          minutesPerDay[i] = data['minutes'] ?? 0;
        } else {
          print("Không tìm thấy dữ liệu cho ngày: $dateKey");
          stepsPerDay[i] = 0;
          caloriesPerDay[i] = 0;
          distancePerDay[i] = 0;
          minutesPerDay[i] = 0;
        }
      } catch (e) {
        print("Lỗi khi truy xuất dữ liệu cho ngày $dateKey: $e");
        stepsPerDay[i] = 0;
        caloriesPerDay[i] = 0;
        distancePerDay[i] = 0;
        minutesPerDay[i] = 0;
      }
    }

    totalSteps = stepsPerDay.reduce((a, b) => a + b);
    totalCalories = caloriesPerDay.reduce((a, b) => a + b);
    totalDistance = distancePerDay.reduce((a, b) => a + b);
    totalMinutes = minutesPerDay.reduce((a, b) => a + b);
    averageSteps = totalSteps / 7;

    print("Tổng số bước: $totalSteps");
    print("Dữ liệu theo ngày:");
    for (int i = 0; i < 7; i++) {
      print("Ngày ${i + 1}: ${stepsPerDay[i]} bước");
    }

    setState(() {});
  }

  Future<void> checkFirestoreStructure(String userId) async {
    try {
      DocumentReference userDocRef =
          _firestore.collection('activity_data').doc(userId);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        print("Tài liệu người dùng tồn tại: ${userDoc.data()}");

        QuerySnapshot dailyDataSnapshot =
            await userDocRef.collection('daily_data').limit(5).get();

        print("Số lượng tài liệu daily_data: ${dailyDataSnapshot.docs.length}");

        for (var doc in dailyDataSnapshot.docs) {
          print("ID tài liệu: ${doc.id}, Dữ liệu: ${doc.data()}");
        }
      } else {
        print(
            "Tài liệu người dùng không tồn tại. Sẽ được tạo khi tải dữ liệu.");
      }
    } catch (e) {
      print("Lỗi khi kiểm tra cấu trúc Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildWeekContent(),
    );
  }

  Widget _buildWeekContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG HÀNG TUẦN',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Từ ngày ${startOfWeek?.day ?? ''} đến ngày ${endOfWeek?.day ?? ''}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalSteps ?? 0} bước',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text('Trung bình ${averageSteps.toStringAsFixed(0)}'),
                    const SizedBox(width: 8),
                    _buildTrendIcon(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeekChart(),
          const Expanded(child: SizedBox()),
          _buildStatItem(
              'bước', totalSteps.toString() ?? '0', Icons.directions_walk),
          _buildStatItem('kcal', totalCalories.toStringAsFixed(1) ?? '0.0',
              Icons.local_fire_department),
          _buildStatItem('km', totalDistance.toStringAsFixed(2) ?? '0.00',
              Icons.directions),
          _buildStatItem('phút', totalMinutes.toString() ?? '0', Icons.timer),
        ],
      ),
    );
  }

  Widget _buildTrendIcon() {
    if (lastWeekAverageSteps == null) {
      return const SizedBox(); // Trả về widget rỗng nếu chưa có dữ liệu tuần trước
    }

    if (averageSteps > lastWeekAverageSteps!) {
      return const Icon(Icons.arrow_upward,
          color: Colors.green, size: 16); // Biểu tượng tăng
    } else if (averageSteps < lastWeekAverageSteps!) {
      return const Icon(Icons.arrow_downward,
          color: Colors.red, size: 16); // Biểu tượng giảm
    } else {
      return const Icon(Icons.horizontal_rule,
          color: Colors.grey, size: 16); // Không thay đổi
    }
  }

  Widget _buildWeekChart() {
    int maxSteps =
        stepsPerDay.reduce((curr, next) => curr > next ? curr : next);
    maxSteps = maxSteps > 0 ? maxSteps : 1; // Tránh chia cho 0
    return Column(
      children: [
        // Hàng hiển thị các thứ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((day) {
            return Expanded(
              child: Center(
                // Căn giữa text thứ
                child: Text(day, style: const TextStyle(color: Colors.grey)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Hàng hiển thị biểu đồ bước
         Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: stepsPerDay.map((steps) {
          return Expanded(
            child: SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 30,
                    height: 150,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: 30,
                    height: (steps / maxSteps) * 150,
                    color: Colors.blue[200],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        ),

        const SizedBox(height: 8),

        // Hàng hiển thị số bước
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stepsPerDay.map((steps) {
            return Expanded(
              child: Center(
                // Căn giữa text số bước
                child: Text(
                  steps > 0 ? steps.toString() : '-',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
