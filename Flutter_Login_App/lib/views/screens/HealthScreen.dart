import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_login_app/views/screens/AddMedicationScreen.dart';
import 'package:flutter_login_app/views/screens/HomeScreen.dart'; // Thêm thư viện này nếu chưa có

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  _HealthScreenState createState() => _HealthScreenState();
}
 class _HealthScreenState extends State<HealthScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildWeightCard(),
                  const SizedBox(height: 16),
                  _buildMedicationCard(),
                  const SizedBox(height: 16),
                  _buildHealthRecordCard(),
                ],
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
          TabItem(icon: Icons.card_giftcard, title: 'Phần thưởng'),
        ],
        initialActiveIndex: 1, // Tab "Sức khoẻ" có index 1
        onTap: (int index) {
          _onItemTapped(index, context); // Điều hướng dựa trên tab được chọn
        },
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    // Xử lý điều hướng khi nhấn các tab
    switch (index) {
      case 0: // Tab 'Trang chủ'
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1: // Tab 'Sức khoẻ' (đã ở trang hiện tại)
        break;
      case 2: // Tab 'Thuốc'
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 3: // Tab 'Phần thưởng'
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Row(
              children: [
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sức khỏe của tôi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow
                        .ellipsis, // Thêm dấu ba chấm nếu text quá dài
                  ),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.person_add), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Sức khỏe'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Sống khỏe'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Chăm sóc'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.monitor_weight, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Cân Nặng',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Chip(
                  label: const Text('BÌNH THƯỜNG'),
                  backgroundColor: Colors.green[100],
                  labelStyle: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('19 THÁNG 9 15:15', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('62 kg',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('+0 kg', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Text('60 NGÀY TRƯỚC', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.medication, color: Colors.pinkAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tuân thủ uống thuốc',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow
                              .ellipsis, // Thêm dấu "..." nếu quá dài
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const AddMedicationScreen(), // Điều hướng đến màn hình thêm thuốc
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  child: const Text('CẬP NHẬT'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TRUNG BÌNH 30 NGÀY',
                        style: TextStyle(color: Colors.grey)),
                    Text('-- %',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TRONG HỘP', style: TextStyle(color: Colors.grey)),
                    Text('-- còn lại',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecordCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.article, color: Colors.blue),
        title:
            const Text('Sổ theo dõi', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Xem tất cả lần đo của bạn'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
