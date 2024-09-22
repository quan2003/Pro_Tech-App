import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // Import for input formatting
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../Routes/AppRoutes.dart';

class AgeInputScreen extends StatefulWidget {
  @override
  _AgeInputScreenState createState() => _AgeInputScreenState();
}

class _AgeInputScreenState extends State<AgeInputScreen> {
  final TextEditingController _yearController = TextEditingController();
  String? _inputYear;

  void _onYearChanged(String year) {
    setState(() {
      _inputYear = year;
    });
  }

  Future<void> _saveYearToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'yearOfBirth': _inputYear,
        }, SetOptions(merge: true));
        Get.snackbar('Thành công', 'Năm sinh của bạn đã được lưu.');
      } catch (e) {
        print('Lỗi khi cập nhật năm sinh: $e');
        Get.snackbar('Lỗi', 'Không thể lưu năm sinh. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text(
                  'Năm sinh của tôi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Độ tuổi ảnh hưởng đến việc theo dõi sức khỏe của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Nhập năm',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  style: TextStyle(fontSize: 18),
                  onChanged: _onYearChanged,
                ),
                SizedBox(height: 40), // Add some spacing for the button
                ElevatedButton(
                  onPressed: _inputYear != null && _inputYear!.isNotEmpty
                      ? () async {
                          await _saveYearToFirestore();
                          Get.toNamed(AppRoutes.HEIGHT_INPUT_SCREEN);
                        }
                      : null,
                  child: Text(
                    'Tiếp tục',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _inputYear != null && _inputYear!.isNotEmpty
                        ? Colors.black
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
