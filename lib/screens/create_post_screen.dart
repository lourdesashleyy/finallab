import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    if (_selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child('post_images/$newPostId.jpg');
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
    Navigator.pop(context); // Go back
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = const Color(0xFF0D1B63);
    final accentColor = Colors.orangeAccent.shade400;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          shadowColor: brandColor.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What's on your mind?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                  decoration: InputDecoration(
                    hintText: "Write something about your favorite team...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: pickImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _selectedImage != null ? 220 : 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedImage != null ? brandColor : Colors.grey.shade400,
                        width: _selectedImage != null ? 2 : 1.2,
                        style: _selectedImage == null ? BorderStyle.solid : BorderStyle.solid,
                      ),
                      boxShadow: _selectedImage != null
                          ? [
                        BoxShadow(
                          color: brandColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                          : [],
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 48,
                            color: brandColor.withOpacity(0.6),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Tap to add image",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: brandColor.withOpacity(0.7),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: createPost,
                    icon: const Icon(Icons.send, size: 22),
                    label: const Text(
                      "Post",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 5,
                      shadowColor: brandColor.withOpacity(0.7),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
