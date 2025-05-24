import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  final String userId;

  const CreatePostScreen({super.key, required this.userId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  Future<void> createPost() async {
    final newPostId = const Uuid().v4();

    await FirebaseFirestore.instance.collection('tbl_posts').doc(newPostId).set({
      'post_id': newPostId,
      'content': _contentController.text.trim(),
      'image_url': _imageUrlController.text.trim(),
      'likes_count': 0,
      'likedUserIds': [],
      'comments_count': 0,
      'timestamp': Timestamp.now(),
      'user_id': widget.userId,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Write your post...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: "Image URL (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: createPost,
              child: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}
