import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;
  final String initialContent;

  const EditPostScreen({
    super.key,
    required this.postId,
    required this.initialContent,
  });

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent);
  }

  Future<void> updatePost() async {
    if (_contentController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('tbl_posts')
        .doc(widget.postId)
        .update({
      'content': _contentController.text.trim(),
      'timestamp': Timestamp.now(), // optional: to mark edit time
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Edit content",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: updatePost,
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
