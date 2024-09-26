import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  _WeekScreenState createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  List<int> stepsPerDay = List.filled(7, 0);
  List<double> caloriesPerDay = List.filled(7, 0);
  List<double> distancePerDay = List.filled(7, 0);
  List<int> minutesPerDay = List.filled(7, 0);
  int totalSteps = 0;
  double averageSteps = 0;
  double totalCalories = 0;
  double totalDistance = 0;
  int totalMinutes = 0;
  double? lastWeekAverageSteps; // Biến lưu trữ số bước trung bình của tuần trước
  DateTime? startOfWeek;
  DateTime? endOfWeek;

  @override
  void initState() {
    super.initState();
    _loadAllDocumentIdsFromFirebase(); // Gọi hàm để lấy tất cả documentId
    _loadDataFromFirebase();
    _loadLastWeekDataFromFirebase(); // Tải dữ liệu của tuần trước
  }
// Hàm để tải dữ liệu tuần trước
  Future<void> _loadLastWeekDataFromFirebase() async {
    DateTime now = DateTime.now();
    DateTime startOfLastWeek = now.subtract(Duration(days: now.weekday + 6)); // Bắt đầu tuần trước
    DateTime endOfLastWeek = startOfLastWeek.add(const Duration(days: 6)); // Kết thúc tuần trước

    List<int> lastWeekSteps = List.filled(7, 0);

    String documentId = "u6S0ve44sHaUyZ8nQSj6PJbEAAA3";

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = startOfLastWeek.add(Duration(days: i));
      String dateKey = "${currentDate.year}-${currentDate.month}-${currentDate.day}";

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('activity_data')
          .doc(documentId)
          .collection('daily_data')
          .doc(dateKey)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        lastWeekSteps[i] = data['steps'] ?? 0;
      }
    }

    int lastWeekTotalSteps = lastWeekSteps.reduce((a, b) => a + b);
    lastWeekAverageSteps = lastWeekTotalSteps / 7; // Tính trung bình tuần trước

    setState(() {}); // Cập nhật UI
  }
  Future<void> _loadDataFromFirebase() async {
  DateTime now = DateTime.now();
  startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Bắt đầu tuần (Thứ 2)
  endOfWeek = startOfWeek!.add(const Duration(days: 6)); // Cuối tuần (Chủ nhật)


 String documentId = "u6S0ve44sHaUyZ8nQSj6PJbEAAA3"; // Sử dụng ID của document chính xác từ Firestore


  for (int i = 0; i < 7; i++) {
    DateTime currentDate = startOfWeek!.add(Duration(days: i));
    // Sửa lại định dạng để phù hợp với Firestore
    String dateKey = "${currentDate.year}-${currentDate.month}-${currentDate.day}";

    print("Truy xuất dữ liệu cho ngày: $dateKey");  // In ra ngày đang truy vấn

    // Lấy dữ liệu từ Firestore cho mỗi ngày trong tuần
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('activity_data')
        .doc(documentId)  // Truy vấn document với ID cụ thể
        .collection('daily_data')  // Truy vấn subcollection 'daily_data'
        .doc(dateKey)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      
      // Kiểm tra xem dữ liệu có tồn tại không
      print("Dữ liệu tìm thấy cho $dateKey: $data");

      stepsPerDay[i] = data['steps'] ?? 0;
      caloriesPerDay[i] = (data['calories'] ?? 0).toDouble();
      distancePerDay[i] = (data['distance'] ?? 0).toDouble();
      minutesPerDay[i] = data['minutes'] ?? 0;
    } else {
      print("Không tìm thấy dữ liệu cho ngày: $dateKey");
    }
  }

  // Tính tổng và trung bình
  totalSteps = stepsPerDay.reduce((a, b) => a + b);
  totalCalories = caloriesPerDay.reduce((a, b) => a + b);
  totalDistance = distancePerDay.reduce((a, b) => a + b);
  totalMinutes = minutesPerDay.reduce((a, b) => a + b);
  averageSteps = totalSteps / 7;

  // In ra tổng số bước để kiểm tra
  print("Tổng số bước: $totalSteps");
  
  // Cập nhật UI
  setState(() {});
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
            'Từ ngày ${startOfWeek!.day}/${startOfWeek!.month} đến ngày ${endOfWeek!.day}/${endOfWeek!.month}', 
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalSteps bước',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text('Trung bình ${averageSteps.toStringAsFixed(0)}'),
                    const SizedBox(width: 8),
                    _buildTrendIcon(), // Hàm hiển thị icon tăng/giảm
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeekChart(),
          const Expanded(child: SizedBox()), // Khoảng trắng mở rộng để tránh chèn các nội dung khác
          _buildStatItem('bước', totalSteps.toString(), Icons.directions_walk),
          _buildStatItem('kcal', totalCalories.toStringAsFixed(1), Icons.local_fire_department),
          _buildStatItem('km', totalDistance.toStringAsFixed(2), Icons.directions),
          _buildStatItem('phút', totalMinutes.toString(), Icons.timer),
        ],
      ),
    );
  }
Widget _buildTrendIcon() {
    if (lastWeekAverageSteps == null) {
      return const SizedBox(); // Trả về widget rỗng nếu chưa có dữ liệu tuần trước
    }

    if (averageSteps > lastWeekAverageSteps!) {
      return const Icon(Icons.arrow_upward, color: Colors.green, size: 16); // Biểu tượng tăng
    } else if (averageSteps < lastWeekAverageSteps!) {
      return const Icon(Icons.arrow_downward, color: Colors.red, size: 16); // Biểu tượng giảm
    } else {
      return const Icon(Icons.horizontal_rule, color: Colors.grey, size: 16); // Không thay đổi
    }
  }

   Widget _buildWeekChart() {
    return Column(
      children: [
        // Hàng hiển thị các thứ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((day) {
            return Expanded(
              child: Center( // Căn giữa text thứ
                child: Text(day, style: const TextStyle(color: Colors.grey)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        
        // Hàng hiển thị biểu đồ bước
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,  // Để căn thẳng hàng với đáy
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
                      height: (steps / 10000) * 150, // Assuming 10000 is max
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
              child: Center( // Căn giữa text số bước
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
Future<void> _loadAllDocumentIdsFromFirebase() async {
  CollectionReference collectionRef = FirebaseFirestore.instance.collection('activity_data');

  // Lấy tất cả document từ bộ sưu tập
  QuerySnapshot querySnapshot = await collectionRef.get();

  // Lấy tất cả documentId
  List<String> documentIds = querySnapshot.docs.map((doc) => doc.id).toList();

  // In ra tất cả documentId
  for (var docId in documentIds) {
    print('Document ID: $docId');
  }

  // Sau đó, bạn có thể sử dụng documentId cho các truy vấn tiếp theo
}