import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentManagementPage extends StatelessWidget {
  const CommentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment Management'),
        backgroundColor: const Color(0xFF00A19D),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts_quiz')
            .where('type', isEqualTo: 'Post')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          List<DocumentSnapshot> posts = snapshot.data!.docs;
          
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('STT')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Likes')),
                DataColumn(label: Text('Comments')),
                DataColumn(label: Text('Actions')),
              ],
              rows: posts.map((post) {
                Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(Text(postData['title'] ?? 'Untitled')),
                    DataCell(Text(postData['likeCount']?.toString() ?? '0')),
                    DataCell(Text(postData['commentCount']?.toString() ?? '0')),
                    DataCell(
                      ElevatedButton(
                        child: const Text('View Comments'),
                        onPressed: () => _showCommentsDialog(context, post.id, postData['title']),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, String postId, String postTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comments for: $postTitle'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts_quiz')
                  .doc(postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                List<DocumentSnapshot> comments = snapshot.data!.docs;
                
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> commentData = comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(commentData['text'] ?? ''),
                      subtitle: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(commentData['userId']).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            Map<String, dynamic>? userData = snapshot.data?.data() as Map<String, dynamic>?;
                            return Text('By: ${userData?['name'] ?? 'Unknown'} (${userData?['email'] ?? 'No email'})');
                          }
                          return const Text('Loading user info...');
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.reply),
                            onPressed: () => _replyToComment(context, postId, comments[index].id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteComment(context, postId, comments[index].id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _replyToComment(BuildContext context, String postId, String commentId) {
    // Implement reply functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController replyController = TextEditingController();
        return AlertDialog(
          title: const Text('Reply to Comment'),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(hintText: "Enter your reply"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Reply'),
              onPressed: () {
                // Add reply to Firestore
                FirebaseFirestore.instance
                    .collection('posts_quiz')
                    .doc(postId)
                    .collection('comments')
                    .doc(commentId)
                    .collection('replies')
                    .add({
                  'text': replyController.text,
                  'user': 'Admin', // You might want to get the actual user
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteComment(BuildContext context, String postId, String commentId) {
    // Implement delete functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('posts_quiz')
                    .doc(postId)
                    .collection('comments')
                    .doc(commentId)
                    .delete()
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comment deleted successfully')));
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete comment: $error')));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}