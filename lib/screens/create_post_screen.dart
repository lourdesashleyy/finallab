import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  final String userId;

  const CreatePostScreen({super.key, required this.userId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _imageFile;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> createPost() async {
    final newPostId = const Uuid().v4();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    String imageUrl = '';

    if (_imageFile != null) {
      final ref = FirebaseStorage.instance.ref().child('post_images/$newPostId.jpg');
      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('tbl_posts').doc(newPostId).set({
      'post_id': newPostId,
      'content': _contentController.text.trim(),
      'image_url': imageUrl,
      'likes_count': 0,
      'likedUserIds': [], // ✅ Initialize as empty list
      'comments_count': 0,
      'timestamp': Timestamp.now(),
      'user_id': userId,
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
            if (_imageFile != null)
              Image.file(_imageFile!, height: 200),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
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
