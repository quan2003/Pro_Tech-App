import 'package:flutter/material.dart';
import 'package:flutter_login_app/views/screens/HealthScreen.dart';
import 'package:flutter_login_app/views/screens/HomeScreen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày tháng
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'BulletinBoardScreen.dart'; // Import ConvexAppBar

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  int _selectedIndex = 2; // The initial index for 'Thuốc' tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // You can add navigation logic for other pages here
    switch (index) {
      case 0:
        Get.to(() => const HomeScreen());
        break;
      case 1:
        Get.to(() => const HealthScreen());
        break;
      case 2:
        Get.to(() =>  const MedicineScreen());
        break;
      case 3:
        Get.to(() => const BulletinBoardScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(top: 50.0), // Thêm khoảng cách ở trên
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thuốc của tôi',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 40.0, // Đặt chiều rộng của hình tròn
                    height: 40.0, // Đặt chiều cao của hình tròn
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 201, 195, 195), // Màu nền của hình tròn
                    ),
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {}, 
                      icon: const Icon(
                        Icons.add, 
                        color: Colors.white, // Màu biểu tượng
                        size: 20.0, // Kích thước biểu tượng
                      ),
                      padding: EdgeInsets.zero, // Xóa padding để biểu tượng nằm chính giữa
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // DateSlider được đặt trực tiếp trong cột
            const DateSlider(),
            const SizedBox(height: 8.0), // Khoảng cách giữa thanh trượt và dòng chữ

            // Dòng chữ "Hôm nay"
            const Center(
              child: TodayText(),
            ),

            // Container cuộn cho thuốc hoặc thông báo không có thuốc
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0), // Khoảng cách bên trong
                  child: Center(
                    child: MedicationList(),
                  ),
                ),
              ),
            ),

            // Nút chỉnh sửa hộp thuốc
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Thêm hành động của nút ở đây
                },
                icon: const Icon(Icons.edit), // Biểu tượng cho nút
                label: const Text('Chỉnh sửa hộp thuốc'), // Văn bản cho nút
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Đặt kích thước tối thiểu
                  textStyle: const TextStyle(fontSize: 16), // Kích thước chữ
                ),
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

class TodayText extends StatelessWidget {
  const TodayText({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now(); // Lấy ngày hôm nay
    return Text(
      'Hôm nay, ${DateFormat('d MMMM yyyy').format(today)}', // Ngày tháng hiện tại
      style: const TextStyle(
        color: Colors.red, // Màu chữ
        fontSize: 16.0, // Kích thước chữ
      ),
    );
  }
}

class MedicationList extends StatelessWidget {
  final List<String> medications = [];

   MedicationList({super.key}); // Danh sách thuốc (hiện tại rỗng)

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) {
      // Hiển thị thông báo nếu không có thuốc
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_box.png', // Đường dẫn tới hình ảnh hộp giấy trống
            height: 100.0, // Chiều cao của hình ảnh
            width: 100.0, // Chiều rộng của hình ảnh
          ),
          const SizedBox(height: 16.0), // Khoảng cách giữa hình ảnh và văn bản
          const Text(
            'Hiện không có thuốc đặt lịch',
            style: TextStyle(fontSize: 16.0, color: Colors.grey), // Màu chữ
          ),
        ],
      );
    } else {
      // Nếu có thuốc, hiển thị danh sách thuốc
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(medications[index]), // Hiển thị tên thuốc
          );
        },
      );
    }
  }
}

class DateSlider extends StatefulWidget {
  const DateSlider({super.key});

  @override
  _DateSliderState createState() => _DateSliderState();
}

class _DateSliderState extends State<DateSlider> {
  final DateTime today = DateTime.now(); // Lấy ngày hôm nay
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cuộn đến ngày hôm nay khi màn hình được xây dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    // Tính toán chỉ số của ngày hôm nay trong danh sách
    int todayIndex = 4; // Chỉ số cho ngày hôm nay (ở giữa danh sách 21 ngày)
    _scrollController.jumpTo(todayIndex * 60.0); // Cuộn đến vị trí cần thiết (60 là chiều rộng của hộp)
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0, // Đặt chiều cao cố định cho thanh trượt ngày
      child: ListView.builder(
        controller: _scrollController, // Thêm ScrollController
        scrollDirection: Axis.horizontal,
        itemCount: 21, // Hiển thị 21 ngày (7 trước, 7 sau, và tuần hiện tại)
        itemBuilder: (context, index) {
          DateTime date = today.add(Duration(days: index - 7)); // Dịch chuyển -7 để bắt đầu 1 tuần trước hôm nay
          
          // Kiểm tra xem ngày hiện tại có khớp với ngày hôm nay không
          bool isToday = date.isAtSameMomentAs(today);

          String dayOfWeek = DateFormat('EEE').format(date); // Ngày trong tuần (Thứ hai, Thứ ba, v.v.)
          String dayOfMonth = DateFormat('d').format(date); // Ngày trong tháng (1, 2, 3, v.v.)
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: isToday // Kiểm tra nếu là ngày hôm nay
                ? Container(
                    width: 60.0, // Đặt chiều rộng của hộp
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Màu nền nếu là hôm nay
                      border: Border.all(color: Colors.grey), // Đường viền màu xám
                      borderRadius: BorderRadius.circular(8.0), // Bo góc hộp
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40.0, // Đặt chiều rộng của vòng tròn
                          height: 40.0, // Đặt chiều cao của vòng tròn
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black, // Màu nền của vòng tròn
                            border: Border.all(color: Colors.grey), // Đường viền
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            dayOfMonth, // Hiển thị ngày trong tháng
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white, // Màu chữ trong vòng tròn
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0), // Khoảng cách giữa vòng tròn và ngày trong tuần
                        Text(
                          dayOfWeek, // Hiển thị ngày trong tuần
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey, // Màu chữ ngày trong tuần
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40.0, // Đặt chiều rộng của vòng tròn
                        height: 40.0, // Đặt chiều cao của vòng tròn
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent, // Màu nền không phải hôm nay
                          border: Border.all(color: Colors.grey), // Đường viền
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dayOfMonth, // Hiển thị ngày trong tháng
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black, // Màu chữ không phải hôm nay
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0), // Khoảng cách giữa vòng tròn và ngày trong tuần
                      Text(
                        dayOfWeek, // Hiển thị ngày trong tuần
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey, // Màu chữ ngày trong tuần
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
