import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:finallab_santosla/widgets/post_card.dart';
import 'package:finallab_santosla/screens/comment_screen.dart';
import 'package:finallab_santosla/screens/edit_post_screen.dart';


class PostsTab extends StatelessWidget {
  final String userId;
  final String currentUsername;  // Add this
  final Future<String> Function(String) getUsername;
  final Future<void> Function(String, String) toggleLike;
  final Future<void> Function(String) deletePost;

  const PostsTab({
    super.key,
    required this.userId,
    required this.currentUsername,
    required this.getUsername,
    required this.toggleLike,
    required this.deletePost,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tbl_posts')
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No posts yet."));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data()! as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final formattedDate =
                "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} "
                "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

            final isLiked = (data['likedUserIds'] as List<dynamic>?)
                ?.contains(userId) ??
                false;

            return FutureBuilder<String>(
              future: getUsername(data['user_id']),
              builder: (context, userSnap) {
                if (!userSnap.hasData) return const SizedBox();
                return PostCard(
                  postId: doc.id,
                  userId: data['user_id'],
                  teamName: userSnap.data!,
                  timeAgo: formattedDate,
                  content: data['content'],
                  imageUrl: data['image_url'],
                  likes: data['likes_count'],
                  comments: data['comments_count'],
                  isOwner: data['user_id'] == userId,
                  currentUsername: currentUsername,
                  isLiked: isLiked,
                  onLike: () => toggleLike(doc.id, userId),
                  onComment: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentScreen(
                          postId: doc.id,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                  onDelete: () => deletePost(doc.id),
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPostScreen(
                          postId: doc.id,
                          initialContent: data['content'],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
