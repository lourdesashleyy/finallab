import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final String userId;

  const CommentScreen({super.key, required this.postId, required this.userId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> addComment(String content) async {
    final newCommentId = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection('tbl_posts')
        .doc(widget.postId)
        .collection('tbl_comments')
        .doc(newCommentId)
        .set({
      'comment': content,
      'timestamp': Timestamp.now(),
      'user_id': widget.userId,
    });

    final postRef = FirebaseFirestore.instance.collection('tbl_posts').doc(widget.postId);
    final postDoc = await postRef.get();
    final current = postDoc['comments_count'] ?? 0;
    await postRef.update({'comments_count': current + 1});
  }

  Future<void> deleteComment(String commentId) async {
    await FirebaseFirestore.instance
        .collection('tbl_posts')
        .doc(widget.postId)
        .collection('tbl_comments')
        .doc(commentId)
        .delete();

    final postRef = FirebaseFirestore.instance.collection('tbl_posts').doc(widget.postId);
    final postDoc = await postRef.get();
    final current = postDoc['comments_count'] ?? 1;
    await postRef.update({'comments_count': current - 1});
  }

  Future<void> editComment(String commentId, String oldContent) async {
    final controller = TextEditingController(text: oldContent);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Comment"),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: "Update your comment"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('tbl_posts')
                    .doc(widget.postId)
                    .collection('tbl_comments')
                    .doc(commentId)
                    .update({'comment': controller.text.trim()});
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tbl_posts')
                  .doc(widget.postId)
                  .collection('tbl_comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text("No comments yet."));

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final comment = data['comment'] ?? '';
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final commentUserId = data['user_id'] ?? '';
                    final commentId = doc.id;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('tbl_Users').doc(commentUserId).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                          return const SizedBox();
                        }

                        final user = userSnapshot.data!;
                        final username = user['username'] ?? 'Unknown';
                        final profileUrl = user['profilePicture'] ?? '';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: profileUrl.isNotEmpty
                                      ? NetworkImage(profileUrl)
                                      : const AssetImage('assets/profile_icon.png') as ImageProvider,
                                  radius: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            username,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          if (widget.userId == commentUserId)
                                            PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == 'edit') editComment(commentId, comment);
                                                if (value == 'delete') deleteComment(commentId);
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                              ],
                                              padding: EdgeInsets.zero,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(comment),
                                      const SizedBox(height: 6),
                                      Text(
                                        timestamp.toString(),
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "Write a comment...",
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0D1B63),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (_commentController.text.trim().isNotEmpty) {
                        await addComment(_commentController.text.trim());
                        _commentController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
