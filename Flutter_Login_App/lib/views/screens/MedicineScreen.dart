import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import '../utils/NotificationService.dart';
import 'HealthScreen.dart';
import 'HomeScreen.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  int _selectedIndex = 2;
  DateTime selectedDate = DateTime.now();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
    _scheduleNotifications();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HealthScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MedicineScreen()),
        );
        break;
    }
  }

  Future<void> _scheduleNotifications() async {
    final medications = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('medications')
        .get();

    for (var med in medications.docs) {
      final data = med.data();
      final schedules = data['schedules'] as List<dynamic>?;
      if (schedules != null) {
        for (var schedule in schedules) {
          final time = schedule['time'] as String;
          final timeParts = time.split(':');
          final now = DateTime.now();
          final scheduledDate = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          if (scheduledDate.isAfter(now)) {
            await _notificationService.showNotification(
              med.id.hashCode,
              'Nhắc nhở uống thuốc',
              'Đã đến giờ uống ${data['drugName']}',
              scheduledDate,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thuốc của tôi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Thêm chức năng thêm thuốc mới
                    },
                  ),
                ],
              ),
            ),
            DateSlider(
              onDateSelected: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  'Hôm nay, ${DateFormat('d MMMM yyyy').format(selectedDate)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: MedicationList(selectedDate: selectedDate),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Chức năng chỉnh sửa hộp thuốc
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Chỉnh sửa hộp thuốc'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: Colors.white,
        activeColor: Colors.pinkAccent,
        color: Colors.grey,
        items: const [
          TabItem(icon: Icons.home, title: 'Trang chủ'),
          TabItem(icon: Icons.favorite, title: 'Sức khoẻ'),
          TabItem(icon: Icons.medication, title: 'Thuốc'),
          TabItem(icon: Icons.forum, title: 'Bảng tin'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DateSlider extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const DateSlider({super.key, required this.onDateSelected});

  @override
  _DateSliderState createState() => _DateSliderState();
}

class _DateSliderState extends State<DateSlider> {
  late PageController _pageController;
  late DateTime _selectedDate;
  final int _daysBeforeAfter = 15;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController =
        PageController(initialPage: _daysBeforeAfter, viewportFraction: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedDate =
                DateTime.now().add(Duration(days: index - _daysBeforeAfter));
            widget.onDateSelected(_selectedDate);
          });
        },
        itemBuilder: (context, index) {
          final date =
              DateTime.now().add(Duration(days: index - _daysBeforeAfter));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MedicationList extends StatelessWidget {
  final DateTime selectedDate;

  const MedicationList({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('medications')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Đã xảy ra lỗi'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> medications = snapshot.data!.docs;

        if (medications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Không có thuốc nào được lên lịch',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        Map<String, List<QueryDocumentSnapshot>> groupedMedications = {
          'Sáng': [],
          'Chiều': [],
          'Tối': [],
        };

        for (var med in medications) {
          String period = _getPeriod(
              med['schedules'] != null && med['schedules'].isNotEmpty
                  ? med['schedules'][0]['time']
                  : '12:00');
          groupedMedications[period]!.add(med);
        }

        return ListView.builder(
          itemCount: groupedMedications.length,
          itemBuilder: (context, index) {
            String period = groupedMedications.keys.elementAt(index);
            List<QueryDocumentSnapshot> meds = groupedMedications[period]!;

            if (meds.isEmpty) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: _getPeriodIcon(period),
                    title: Text(
                      period.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle:
                        Text('Nhắc nhở tiếp theo: ${_getNextReminder(meds)}'),
                    trailing: ElevatedButton(
                      onPressed: () => _takeMedications(meds),
                      child: const Text('Uống tất cả'),
                    ),
                  ),
                  const Divider(),
                  ...meds.map((med) => MedicationItem(medication: med)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getNextReminder(List<QueryDocumentSnapshot> medications) {
    DateTime now = DateTime.now();
    DateTime? nextReminder;
    for (var med in medications) {
      final schedules = med['schedules'] as List<dynamic>?;
      if (schedules != null) {
        for (var schedule in schedules) {
          final time = schedule['time'] as String;
          final timeParts = time.split(':');
          final scheduledDate = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          if (scheduledDate.isAfter(now) &&
              (nextReminder == null || scheduledDate.isBefore(nextReminder))) {
            nextReminder = scheduledDate;
          }
        }
      }
    }
    return nextReminder != null
        ? DateFormat('HH:mm').format(nextReminder)
        : 'Không có';
  }

  String _getPeriod(String time) {
    int hour = int.parse(time.split(':')[0]);
    if (hour < 12) return 'Sáng';
    if (hour < 18) return 'Chiều';
    return 'Tối';
  }

  Icon _getPeriodIcon(String period) {
    switch (period) {
      case 'Sáng':
        return const Icon(Icons.wb_sunny, color: Colors.orange);
      case 'Chiều':
        return const Icon(Icons.wb_twighlight, color: Colors.amber);
      case 'Tối':
        return const Icon(Icons.nightlight_round, color: Colors.indigo);
      default:
        return const Icon(Icons.access_time);
    }
  }

  void _takeMedications(List<QueryDocumentSnapshot> medications) {
    for (var med in medications) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('medications')
          .doc(med.id)
          .update({'taken': true});
    }
  }
}

class MedicationItem extends StatelessWidget {
  final QueryDocumentSnapshot medication;

  const MedicationItem({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = medication.data() as Map<String, dynamic>;
    final String name = data['drugName'] ?? 'Không có tên';
    final String dosage = data['dosage'] ?? 'Không có liều lượng';
    final List<dynamic> schedules = data['schedules'] ?? [];
    final String time =
        schedules.isNotEmpty ? schedules[0]['time'] : 'Không có thời gian';
    final bool taken = data['taken'] ?? false;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.medication,
          color: taken ? Colors.green : Colors.grey,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$dosage - $time'),
        trailing: IconButton(
          icon: Icon(
            taken ? Icons.check_circle : Icons.circle_outlined,
            color: taken ? Colors.green : Colors.grey,
          ),
          onPressed: () {
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('medications')
                .doc(medication.id)
                .update({'taken': !taken});
          },
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(name),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Liều lượng: $dosage'),
                  Text('Thời gian: $time'),
                  Text('Đã uống: ${taken ? 'Có' : 'Chưa'}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
