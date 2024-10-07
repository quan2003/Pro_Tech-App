import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class AdminPostDetailPage extends StatefulWidget {
  final String postId;

  const AdminPostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  _AdminPostDetailPageState createState() => _AdminPostDetailPageState();
}

class _AdminPostDetailPageState extends State<AdminPostDetailPage> {
  final TextEditingController _markdownController = TextEditingController();
  bool _isPreview = false;
  String? _currentDetailId;

  @override
  void initState() {
    super.initState();
    _loadLatestDetail();
  }

  @override
  void dispose() {
    _markdownController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestDetail() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts_quiz')
        .doc(widget.postId)
        .collection('PostDetail')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      setState(() {
        _markdownController.text = doc['detail'] ?? '';
        _currentDetailId = doc.id;
      });
    }
  }

  void _togglePreview() {
    setState(() {
      _isPreview = !_isPreview;
    });
  }

  Future<void> _savePostDetail() async {
    if (_markdownController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    try {
      if (_currentDetailId != null) {
        // Update existing detail
        await FirebaseFirestore.instance
            .collection('posts_quiz')
            .doc(widget.postId)
            .collection('PostDetail')
            .doc(_currentDetailId)
            .update({
          'detail': _markdownController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new detail
        await FirebaseFirestore.instance
            .collection('posts_quiz')
            .doc(widget.postId)
            .collection('PostDetail')
            .add({
          'detail': _markdownController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PostDetail saved successfully')),
      );
      _loadLatestDetail(); // Reload to get the latest version
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PostDetail: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Edit Post Detail'),
        actions: [
          IconButton(
            icon: Icon(_isPreview ? Icons.edit : Icons.preview),
            onPressed: _togglePreview,
            tooltip: _isPreview ? 'Edit' : 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePostDetail,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isPreview
                ? Markdown(data: _markdownController.text)
                : TextField(
                    controller: _markdownController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your markdown here...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
          ),
          _buildDetailHistory(),
        ],
      ),
    );
  }

  Widget _buildDetailHistory() {
    return Container(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts_quiz')
            .doc(widget.postId)
            .collection('PostDetail')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              var timestamp = data['timestamp'] as Timestamp?;
              var formattedDate = timestamp != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())
                  : 'No date';

              return ListTile(
                title: Text('Version ${snapshot.data!.docs.length - index}'),
                subtitle: Text(formattedDate),
                onTap: () {
                  setState(() {
                    _markdownController.text = data['detail'] ?? '';
                    _currentDetailId = doc.id;
                    _isPreview = false;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}