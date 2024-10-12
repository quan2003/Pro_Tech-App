import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'ChatScreen.dart'; // Import để khởi tạo dữ liệu ngôn ngữ

class WeightInputTodayScreen extends StatefulWidget {
  const WeightInputTodayScreen({super.key});

  @override
  _WeightInputTodayScreenState createState() => _WeightInputTodayScreenState();
}

class _WeightInputTodayScreenState extends State<WeightInputTodayScreen> {
  double _weight = 62;
  final double _minWeight = 0;
  final double _maxWeight = 300;
  String _unit = 'kg';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(
        'vi', null); // Khởi tạo dữ liệu cho ngôn ngữ Tiếng Việt
  }

  Future<void> _selectDate(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    const Text(
                      'Đặt ngày',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: _selectedDate,
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text('Hoàn tất',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  String _getFormattedDate() {
    if (_selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day) {
      return 'Hôm nay, ${DateFormat('d MMMM yyyy', 'vi').format(_selectedDate)}';
    } else {
      return '${DateFormat('EEEE', 'vi').format(_selectedDate)}, ${DateFormat('d MMMM yyyy', 'vi').format(_selectedDate)}';
    }
  }

  double _convertWeightToSelectedUnit(double weight) {
    switch (_unit) {
      case 'lbs':
        return weight * 2.20462;
      case 'st':
        return weight * 0.157473;
      default:
        return weight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
        ],
        title: const Text(
          'Cân nặng',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: const Color.fromARGB(157, 255, 255, 255),
                  border: Border.all(color: Colors.grey),
                  borderRadius:
                      BorderRadius.circular(30), // Viền bo tròn cho giống ảnh
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12), // Cân đối padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getFormattedDate(),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.pink, size: 40),
                  onPressed: () {
                    setState(() {
                      if (_weight > _minWeight) {
                        _weight--;
                      }
                    });
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  _convertWeightToSelectedUnit(_weight).toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 64, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Colors.pink, size: 40),
                  onPressed: () {
                    setState(() {
                      if (_weight < _maxWeight) {
                        _weight++;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              borderRadius: BorderRadius.circular(20),
              selectedColor: Colors.white,
              fillColor: Colors.pink,
              isSelected: [_unit == 'kg', _unit == 'lbs', _unit == 'st'],
              onPressed: (int index) {
                setState(() {
                  if (index == 0) {
                    _unit = 'kg';
                  } else if (index == 1) {
                    _unit = 'lbs';
                  } else if (index == 2) {
                    _unit = 'st';
                  }
                });
              },
              children: const [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text('kg', style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text('lbs', style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text('st', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Slider(
              value: _weight,
              min: _minWeight,
              max: _maxWeight,
              onChanged: (double value) {
                setState(() {
                  _weight = value;
                });
              },
              activeColor: Colors.pink,
              inactiveColor: Colors.grey,
              divisions: 300,
              label: _convertWeightToSelectedUnit(_weight).toStringAsFixed(1),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Color.fromARGB(255, 0, 0, 0)),
                  onPressed: () {
                   User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Get.to(() => ChatScreen(
                        userId: user.uid,
                        predefinedMessage: 'Đo cân nặng như thế nào?'));
                    } 
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Đo cân nặng như thế nào?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 0, 0, 0),
                     ),
                ),
                 const Icon(Icons.chevron_right, color: Color.fromARGB(255, 0, 0, 0))
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}