import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('posts_quiz')
            .doc(widget.postId)
            .collection('comments')
            .add({
          'userId': user.uid,
          'comment': _commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Increment comment count
        await _firestore.collection('posts_quiz').doc(widget.postId).update({
          'commentCount': FieldValue.increment(1),
        });

        _commentController.clear();
      }
    }
  }

  Future<void> _toggleLike() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference postRef =
          _firestore.collection('posts_quiz').doc(widget.postId);
      DocumentSnapshot postDoc = await postRef.get();

      if (postDoc.exists) {
        List<String> likes = List<String>.from(postDoc.get('likes') ?? []);
        if (likes.contains(user.uid)) {
          likes.remove(user.uid);
        } else {
          likes.add(user.uid);
        }
        await postRef.update({
          'likes': likes,
          'likeCount': likes.length,
        });
      }
    }
  }

  Widget _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return SizedBox.shrink();
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());
    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours} giờ trước';
    } else {
      timeAgo = '${difference.inDays} ngày trước';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey),
        SizedBox(width: 4),
        Text(timeAgo, style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Chi tiết bài viết', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.pink),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            _firestore.collection('posts_quiz').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Bài viết không tồn tại'));
          }

          var postData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          List<String> likes = List<String>.from(postData['likes'] ?? []);
          bool isLiked = likes.contains(_auth.currentUser?.uid);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (postData['imageUrl'] != null)
                  Image.network(
                    postData['imageUrl'] as String,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRO - TECH',
                        style: TextStyle(
                            color: Colors.pink, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        postData['title'] as String? ?? 'Không có tiêu đề',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      _formatTimestamp(postData['timestamp'] as Timestamp?),
                      SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('posts_quiz')
                            .doc(widget.postId)
                            .collection('PostDetail')
                            .orderBy('timestamp', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return SizedBox();
                          String detailContent = snapshot.data!.docs
                              .map((doc) => doc['detail'] as String? ?? '')
                              .join('\n\n');
                          return MarkdownBody(data: detailContent);
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey),
                          SizedBox(width: 8),
                          Text('${postData['likeCount'] ?? 0}'),
                          SizedBox(width: 16),
                          Icon(Icons.comment, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('${postData['commentCount'] ?? 0}'),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _toggleLike,
                        child: Text(isLiked ? 'Bỏ thích' : 'Thích bài viết'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLiked ? Colors.grey : Colors.pink,
                          minimumSize: Size(double.infinity, 40),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Nhận xét:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('posts_quiz')
                            .doc(widget.postId)
                            .collection('comments')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return SizedBox();
                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              var data = doc.data() as Map<String, dynamic>;
                              return FutureBuilder<DocumentSnapshot>(
                                future: _firestore
                                    .collection('users')
                                    .doc(data['userId'])
                                    .get(),
                                builder: (context, userSnapshot) {
                                  String userName = 'Người dùng';
                                  if (userSnapshot.hasData &&
                                      userSnapshot.data != null &&
                                      userSnapshot.data!.exists) {
                                    userName = (userSnapshot.data!.data()
                                                as Map<String, dynamic>?)?[
                                            'name'] ??
                                        'Người dùng';
                                  }
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(userName[0].toUpperCase()),
                                    ),
                                    title: Text(userName),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(data['comment'] as String? ?? ''),
                                        _formatTimestamp(
                                            data['timestamp'] as Timestamp?),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Viết nhận xét...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.pink),
              onPressed: _addComment,
            ),
          ],
        ),
      ),
    );
  }
}
