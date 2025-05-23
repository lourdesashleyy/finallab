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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No comments yet."));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final comment = data['comment'] ?? '';
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final commentUserId = data['user_id'] ?? '';

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('tbl_Users')
                          .doc(commentUserId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                          return const ListTile(title: Text("Loading user..."));
                        }

                        final user = userSnapshot.data!;
                        final username = user['username'] ?? 'Unknown';
                        final profileUrl = user['profilePicture'] ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: profileUrl.isNotEmpty
                                ? NetworkImage(profileUrl)
                                : const AssetImage('assets/profile_icon.png') as ImageProvider,
                          ),
                          title: Text(username),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment),
                              Text(
                                timestamp.toString(),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_commentController.text.isNotEmpty) {
                      await addComment(_commentController.text.trim());
                      _commentController.clear();
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
