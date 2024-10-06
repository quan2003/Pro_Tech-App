import 'package:flutter/material.dart';

class KimchiRecipeScreen extends StatelessWidget {
  const KimchiRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    'assets/images/kimchi_header.png',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Positioned(
                    top: 16,
                    right: 16,
                    child: Icon(Icons.share, color: Colors.white),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRO-TECH',
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Công thức kimchi tăng cường miễn dịch',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'một ngày trước',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bổ sung thực phẩm lên men như kimchi vào chế độ ăn không chỉ là cách ngon miệng để hỗ trợ hệ miễn dịch mà còn cải thiện sức khoẻ đường ruột và quản lý các bệnh mạn tính như tiểu đường. Món ăn truyền thống Hàn Quốc này không chỉ là một món phụ hấp dẫn, mà còn chứa nhiều probiotics và dưỡng chất có thể giúp cải thiện sức khoẻ toàn diện của bạn.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tại Pro-Tech, chúng tôi luôn khuyến khích cộng đồng cùng chia sẻ bí quyết, công thức nấu ăn, và động viên nhau để sống khoẻ mạnh hơn mỗi ngày. Hãy cùng nhau khám phá cách...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}