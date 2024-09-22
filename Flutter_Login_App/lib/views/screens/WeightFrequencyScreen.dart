import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Routes/AppRoutes.dart';

class WeightFrequencyScreen extends StatefulWidget {
  @override
  _WeightFrequencyScreenState createState() => _WeightFrequencyScreenState();
}

class _WeightFrequencyScreenState extends State<WeightFrequencyScreen> {
  // Variable to keep track of the selected frequency
  int _frequency = 4;

  Future<void> _saveFrequencyToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'weight_frequency': _frequency,
        }, SetOptions(merge: true));
        Get.snackbar('Thành công', 'Tần suất của bạn đã được lưu.');
      } catch (e) {
        Get.snackbar('Lỗi', 'Không thể lưu tần suất. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cân nặng',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Tùy chỉnh tần suất theo dõi của bạn',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Frequency Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        if (_frequency > 1) _frequency--;
                      });
                    },
                    iconSize: 40,
                  ),
                  SizedBox(width: 20),
                  Text(
                    '$_frequency',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _frequency++;
                      });
                    },
                    iconSize: 40,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'lần mỗi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'tuần',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Kế hoạch tùy chỉnh cá nhân (cần được sự đồng ý của bác sĩ)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Save Button
              ElevatedButton(
                onPressed: () async {
                  await _saveFrequencyToFirestore();
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.HOMESCREEN);
                },
                child: Text(
                  'Lưu',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
