import 'package:flutter/material.dart';
import 'package:flutter_login_app/views/screens/BMIScreen.dart';
import 'package:flutter_login_app/views/screens/FirstDayIntroduction.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'ProfileScreen.dart';
import '../Routes/AppRoutes.dart';
import 'package:intl/intl.dart';
import 'ChatScreen.dart';
import '../controller/BMIController.dart';
import 'AccountDataScreen.dart';
import 'AboutUsScreen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BMIController bmiController = Get.put(BMIController());

  // BottomNavigationBar index
  int _selectedIndex = 0;

  // Method to handle bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to fetch user data from Firestore
  Future<String> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc['name'] ?? 'Khách';
      }
    }
    return 'Khách';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        String userName = snapshot.data ?? 'Khách';
        User? user = FirebaseAuth.instance.currentUser;

        // Get current date and time
        String formattedDate =
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
        String formattedTime = DateFormat('HH:mm').format(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: const Text("Trang chủ"),
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: Icon(Icons.message),
                onPressed: () {
                  if (user != null) {
                    Get.to(() => ChatScreen(userId: user.uid));
                  } else {
                    Get.snackbar(
                        'Lỗi', 'Vui lòng đăng nhập trước khi trò chuyện.');
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () async {
                  NotificationSettings settings =
                      await FirebaseMessaging.instance.requestPermission();

                  if (settings.authorizationStatus ==
                      AuthorizationStatus.authorized) {
                    Get.snackbar('Thành công', 'Bạn đã cấp quyền thông báo.');
                  } else {
                    Get.snackbar('Lỗi', 'Bạn đã từ chối quyền thông báo.');
                  }
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // Drawer Header
                UserAccountsDrawerHeader(
                  accountName: Text(userName),
                  accountEmail: Text(user?.email ?? 'Không có email'),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person), // Profile Icon
                  title: Text('Hồ sơ'),
                  onTap: () {
                    // Navigate to the profile screen
                    Get.to(() => ProfileScreen(userId: user!.uid));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info), // App version icon
                  title: Text('Phiên bản ứng dụng'),
                  onTap: () {
                    // Logic for displaying app version
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle), // Account and data icon
                  title: Text('Tài khoản & dữ liệu'),
                  onTap: () {
                    Get.to(() => AccountDataScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.language), // Language icon
                  title: Text('Ngôn ngữ'),
                  onTap: () {
                    // Logic for changing language
                  },
                ),
                ListTile(
                  leading: Icon(Icons.public), // Country icon
                  title: Text('Quốc gia'),
                  onTap: () {
                    // Logic for changing country settings
                  },
                ),
                Divider(), // Add a divider to separate sections
                // Health Section
                ListTile(
                  leading: Icon(Icons.health_and_safety),
                  title: Text('Tình trạng sức khỏe'),
                  onTap: () {
                    // Navigate to Health Status
                  },
                ),
                ListTile(
                  leading: Icon(Icons.assessment),
                  title: Text('Kế hoạch sức khỏe'),
                  onTap: () {
                    // Navigate to Health Plan
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_hospital),
                  title: Text('Bệnh viện / bác sĩ'),
                  onTap: () {
                    // Navigate to Hospitals/Doctors
                  },
                ),
                ListTile(
                  leading: Icon(Icons.assignment),
                  title: Text('Đơn vị'),
                  onTap: () {
                    // Navigate to Health Units
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Hướng dẫn sức khỏe'),
                  onTap: () {
                    // Navigate to Health Guidance
                  },
                ),

                // Access Permissions Section
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Thông báo'),
                  onTap: () {
                    // Navigate to Notification Settings
                  },
                ),
                ListTile(
                  leading: Icon(Icons.apps),
                  title: Text('Ứng dụng sức khỏe'),
                  onTap: () {
                    // Navigate to Health Apps
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bluetooth),
                  title: Text('Thiết bị Bluetooth'),
                  onTap: () {
                    // Navigate to Bluetooth Devices
                  },
                ),

                // Introduction and Information Section
                Divider(),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Về chúng tôi'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.article),
                  title: Text('Giới thiệu về Ngày Đầu Tiên'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Firstdayintroduction()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.rule),
                  title: Text('Điều khoản & điều kiện'),
                  onTap: () {
                    // Terms & Conditions
                  },
                ),
                ListTile(
                  leading: Icon(Icons.privacy_tip),
                  title: Text('Chính sách bảo mật'),
                  onTap: () {
                    // Privacy Policy
                  },
                ),
                ListTile(
                  leading: Icon(Icons.policy),
                  title: Text('Quy tắc Trò chơi hóa'),
                  onTap: () {
                    // Gamification Rules
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cookie),
                  title: Text('Chính sách Cookie'),
                  onTap: () {
                    // Cookie Policy
                  },
                ),

                // Logout Section
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offNamed(AppRoutes.SIGNINSCREEN);
                  },
                ),
              ],
            ),
          ),
          // ... (remaining drawer items)
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào, $userName!',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$formattedDate, $formattedTime',
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.alarm,
                              color: Colors.teal), // Change to alarm icon
                          onPressed: () {
                            // _scheduleAlarm(); // Calls the method to schedule an alarm
                            Get.snackbar('Báo thức',
                                'Báo thức đã được đặt trong 10 giây tới.');
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Health Overview Card
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.health_and_safety,
                                    color: Colors.teal),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Chỉ số khối cơ thể (BMI)',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.help_outline,
                                      color: Colors.teal),
                                  onPressed: () {
                                    Get.to(() => ChatScreen(
                                        userId: user!.uid,
                                        predefinedMessage:
                                            'Cách tính chỉ số BMI?'));
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // BMI Gauge Chart
                            Container(
                              height: 250,
                              child: Obx(() {
                                double bmi = bmiController.bmiValue.value;
                                return SfRadialGauge(
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                      minimum: 10,
                                      maximum: 40,
                                      showLabels: false,
                                      showTicks: false,
                                      ranges: <GaugeRange>[
                                        GaugeRange(
                                          startValue: 10,
                                          endValue: 18.5,
                                          color: Colors.blue,
                                          startWidth: 20,
                                          endWidth: 20,
                                        ),
                                        GaugeRange(
                                          startValue: 18.5,
                                          endValue: 25,
                                          color: Colors.green,
                                          startWidth: 20,
                                          endWidth: 20,
                                        ),
                                        GaugeRange(
                                          startValue: 25,
                                          endValue: 30,
                                          color: Colors.orange,
                                          startWidth: 20,
                                          endWidth: 20,
                                        ),
                                        GaugeRange(
                                          startValue: 30,
                                          endValue: 40,
                                          color: Colors.red,
                                          startWidth: 20,
                                          endWidth: 20,
                                        ),
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(
                                          value: bmi,
                                          enableAnimation: true,
                                          animationType:
                                              AnimationType.easeOutBack,
                                        ),
                                      ],
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                bmi.toStringAsFixed(1),
                                                style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                bmiController.bmiCategory.value,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: bmiController
                                                      .bmiColor.value,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          angle: 90,
                                          positionFactor: 0.75,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.pinkAccent,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety),
                label: 'Sức khoẻ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medication),
                label: 'Thuốc',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard),
                label: 'Phần thưởng',
              ),
            ],
          ),
        );
      },
    );
  }
}
