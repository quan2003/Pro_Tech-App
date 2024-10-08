import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class AdminPostDetailPage extends StatefulWidget {
  final String postId;

  const AdminPostDetailPage({super.key, required this.postId});

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
    try {
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
    } catch (e) {
      _showErrorSnackBar('Error loading latest detail: $e');
    }
  }

  void _togglePreview() {
    setState(() {
      _isPreview = !_isPreview;
    });
  }

  Future<void> _savePostDetail() async {
    if (_markdownController.text.isEmpty) {
      _showErrorSnackBar('Please enter some content');
      return;
    }

    try {
      final postDetailRef = FirebaseFirestore.instance
          .collection('posts_quiz')
          .doc(widget.postId)
          .collection('PostDetail');

      final data = {
        'detail': _markdownController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_currentDetailId != null) {
        await postDetailRef.doc(_currentDetailId).update(data);
      } else {
        await postDetailRef.add(data);
      }

      _showSuccessSnackBar('PostDetail saved successfully');
      await _loadLatestDetail();
    } catch (e) {
      _showErrorSnackBar('Error saving PostDetail: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildWideLayout();
            } else {
              return _buildNarrowLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildEditor(),
        ),
        Expanded(
          flex: 1,
          child: _buildDetailHistory(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        Expanded(
          child: _buildEditor(),
        ),
        SizedBox(
          height: 200,
          child: _buildDetailHistory(),
        ),
      ],
    );
  }

  Widget _buildEditor() {
    return _isPreview
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
          );
  }

  Widget _buildDetailHistory() {
    return StreamBuilder<QuerySnapshot>(
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
          return const Center(child: CircularProgressIndicator());
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
    );
  }
}