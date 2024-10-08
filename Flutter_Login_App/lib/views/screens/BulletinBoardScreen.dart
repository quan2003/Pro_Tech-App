import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// For formatting dates

import 'HealthScreen.dart';
import 'HomeScreen.dart';
import 'MedicineScreen.dart';
import 'PostDetailScreen.dart';

class BulletinBoardScreen extends StatefulWidget {
  const BulletinBoardScreen({super.key});

  @override
  _BulletinBoardScreenState createState() => _BulletinBoardScreenState();
}

class _BulletinBoardScreenState extends State<BulletinBoardScreen> {
  int _selectedIndex = 3;
  Map<String, String?> selectedOptions = {};

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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts_quiz')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Không có bài đăng nào.'));
                    }
                    int parseNumericValue(dynamic value) {
                      if (value == null) return 0;
                      if (value is int) return value;
                      if (value is double) return value.toInt();
                      if (value is String) return int.tryParse(value) ?? 0;
                      if (value is List && value.isNotEmpty) {
                        return parseNumericValue(value.first);
                      }
                      return 0;
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String docId = document.id;

                        String imageUrl = data['imageUrl'] ?? '';
                        String title = data['title'] ?? 'Không có tiêu đề';
                        String description = data['description'] ?? '';
                        Timestamp? timestamp = data['timestamp'] as Timestamp?;

                        if (description.isEmpty && timestamp != null) {
                          description =
                              _generateTimeBasedDescription(timestamp);
                        }

                        List<String> options =
                            List<String>.from(data['options'] ?? []);
                        int responses = parseNumericValue(data['responses']);
                        String? correctOption =
                            data['correctAnswer']?.toString();
                        String? type = data['type'];
                        int views = parseNumericValue(data['views']);
                        int commentCount =
                            parseNumericValue(data['commentCount']);
                        int likeCount = parseNumericValue(data['likeCount']);

                        return _buildBulletinCard(
                          docId: docId,
                          imageAsset: imageUrl,
                          title: title,
                          description: description,
                          options: options,
                          responses: responses,
                          correctOption: correctOption,
                          type: type,
                          views: views,
                          likeCount: likeCount,
                          commentCount: commentCount,
                        );
                      }).toList(),
                    );
                  },
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

  // Function to generate time-based description
  String _generateTimeBasedDescription(Timestamp timestamp) {
    DateTime postTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(postTime);

    if (difference.inMinutes < 1) {
      return 'Pro - Tech: Vừa xong';
    } else if (difference.inMinutes < 60) {
      return 'Pro - Tech: ${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return 'Pro - Tech: ${difference.inHours} giờ trước';
    } else {
      return 'Pro - Tech: ${difference.inDays} ngày trước';
    }
  }

  Widget _buildBulletinCard({
    required String docId,
    String? imageAsset,
    required String title,
    required String description,
    required List<String> options,
    int responses = 0,
    String? correctOption,
    String? type,
    int views = 0,
    int likeCount = 0,
    int commentCount = 0,
  }) {
    return Card(
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
            if (imageAsset != null && imageAsset.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
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
            if (type?.toLowerCase() == 'quiz')
              Column(
                children: options.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;

                  bool isCorrect = int.tryParse(correctOption ?? '') == index;
                  bool isSelected = selectedOptions[docId] == option;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOptions[docId] = option;
                        _incrementQuizResponses(docId);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isCorrect ? Colors.green[100] : Colors.red[100])
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? (isCorrect ? Colors.green : Colors.red)
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          if (isSelected)
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            if (type?.toLowerCase() == 'post') ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text('$views lượt xem',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text('$likeCount lượt thích',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text('$commentCount bình luận',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _incrementPostViews(docId);
                    _showPostDetails(docId);
                  },
                  child: const Text('Xem chi tiết'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              type?.toLowerCase() == 'quiz'
                  ? '$responses người đã trả lời'
                  : '$views lượt xem',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show post details in a new page or dialog
  void _showPostDetails(String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: docId),
      ),
    );
  }

  void _incrementQuizResponses(String docId) {
    FirebaseFirestore.instance
        .collection('posts_quiz')
        .doc(docId)
        .update({'responses': FieldValue.increment(1)});
  }

  void _incrementPostViews(String docId) {
    FirebaseFirestore.instance
        .collection('posts_quiz')
        .doc(docId)
        .update({'views': FieldValue.increment(1)});
  }
}
