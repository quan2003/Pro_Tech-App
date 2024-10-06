import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'HealthScreen.dart';
import 'HomeScreen.dart';
import 'KimchiRecipeScreen.dart';
import 'MedicineScreen.dart';

class BulletinBoardScreen extends StatefulWidget {
  const BulletinBoardScreen({super.key});

  @override
  _BulletinBoardScreenState createState() => _BulletinBoardScreenState();
}

class _BulletinBoardScreenState extends State<BulletinBoardScreen> {
  String selectedOption = "";
  String correctOption = "Theo dõi đường huyết thường xuyên và duy trì vận động";
  int _selectedIndex = 3; // Set to 3 for 'Bảng tin' tab

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Bảng tin cộng đồng',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildBulletinCard(
                      imageAsset: 'assets/images/quiz_header.png',
                      title: 'Chiến lược quan trọng nào giúp quản lý tiểu đường hiệu quả?',
                      description: 'Trắc nghiệm nhận thưởng',
                      options: [
                        'Bỏ bữa để tránh tăng đường huyết',
                        'Theo dõi đường huyết thường xuyên và duy trì vận động',
                        'Ăn nhiều tinh bột để có năng lượng'
                      ],
                      responses: '1,21 nghìn người đã trả lời',
                    ),
                    _buildBulletinCard(
                      imageAsset: 'assets/images/kimchi_header.png',
                      title: 'Công thức kimchi tăng cường miễn dịch',
                      description: 'Bổ sung thực phẩm lên men như kimchi vào chế độ ăn không chỉ là các...',
                      responses: 'Pro-tech • một ngày trước',
                      options: [],
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildBulletinCard({
    String? imageAsset,
    required String title,
    required String description,
    required List<String> options,
    required String responses,
  }) {
    return GestureDetector(
      onTap: () {
        if (title.contains('kimchi')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KimchiRecipeScreen()),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageAsset != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ...options.map((option) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = option;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: selectedOption == option
                            ? (option == correctOption ? Colors.green[100] : Colors.red[100])
                            : Colors.white,
                        border: Border.all(
                          color: selectedOption == option
                              ? (option == correctOption ? Colors.green : Colors.red)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          if (selectedOption == option)
                            Icon(
                              option == correctOption ? Icons.check_circle : Icons.cancel,
                              color: option == correctOption ? Colors.green : Colors.red,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedOption == option
                                    ? (option == correctOption ? Colors.green : Colors.red)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    responses,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}