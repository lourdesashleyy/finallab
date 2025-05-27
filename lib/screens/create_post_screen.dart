import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final picker = ImagePicker();
  File? _selectedImage;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> createPost() async {
    final newPostId = const Uuid().v4();
    String? imageUrl;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    if (_selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images/$newPostId.jpg');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print("Image upload failed: $e");
      }
    }

    await FirebaseFirestore.instance.collection('tbl_posts').doc(newPostId).set({
      'post_id': newPostId,
      'content': _contentController.text.trim(),
      'image_url': imageUrl ?? '',
      'likes_count': 0,
      'likedUserIds': [],
      'comments_count': 0,
      'timestamp': Timestamp.now(),
      'user_id': widget.userId,
    });

    Navigator.pop(context); // Close loading dialog
    Navigator.pop(context); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            GestureDetector(
              onTap: pickImage,
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, height: 200)
                  : Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                ),
                child: const Center(child: Text("Tap to add image")),
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
