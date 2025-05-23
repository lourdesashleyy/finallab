import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:finallab_santosla/screens/create_post_screen.dart';
import 'package:finallab_santosla/screens/edit_post_screen.dart';
import 'package:finallab_santosla/screens/comment_screen.dart';
import 'package:finallab_santosla/widgets/post_card.dart';
import 'profile.dart';

class HomePage extends StatelessWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  Stream<QuerySnapshot> getPostsStream() {
    return FirebaseFirestore.instance
        .collection('tbl_posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String> getUsername(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('tbl_Users').doc(userId).get();
      return doc.exists ? (doc.data()?['username'] ?? 'Unknown User') : 'Unknown User';
    } catch (_) {
      return 'Unknown User';
    }
  }

  Future<void> toggleLike(String postId, String currentUserId) async {
    final postRef = FirebaseFirestore.instance.collection('tbl_posts').doc(postId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);

      if (!snapshot.exists) {
        throw Exception("Post does not exist");
      }

      final data = snapshot.data()!;
      final currentLikes = data['likes_count'] ?? 0;
      final List<dynamic> likedUserIds = data['likedUserIds'] ?? [];

      if (likedUserIds.contains(currentUserId)) {
        // Unlike
        transaction.update(postRef, {
          'likes_count': currentLikes > 0 ? currentLikes - 1 : 0,
          'likedUserIds': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Like
        transaction.update(postRef, {
          'likes_count': currentLikes + 1,
          'likedUserIds': FieldValue.arrayUnion([currentUserId]),
        });
      }
    });
  }


  Future<void> deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('tbl_posts').doc(postId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFF0D1B63),
        actions: [
          IconButton(
            onPressed: () async {
              final doc = await FirebaseFirestore.instance.collection('tbl_Users').doc(currentUserId).get();
              final username = doc.data()?['username'] ?? 'Unknown User';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(username: username),
                ),
              );
            },
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/profile_icon.png'),
              radius: 16,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreatePostScreen(userId: currentUserId)),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF0D1B63),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPostsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedDate =
                  "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} "
                  "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

              final isLiked = (data['likedUserIds'] as List<dynamic>?)
                  ?.contains(currentUserId) ??
                  false;

              return FutureBuilder<String>(
                future: getUsername(data['user_id']),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) return const SizedBox();
                  return PostCard(
                    postId: doc.id,
                    teamName: userSnap.data!,
                    timeAgo: formattedDate,
                    content: data['content'],
                    imageUrl: data['image_url'],
                    likes: data['likes_count'],
                    comments: data['comments_count'],
                    isOwner: data['user_id'] == currentUserId,
                    isLiked: isLiked,
                    onLike: () => toggleLike(doc.id, currentUserId),
                    onComment: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommentScreen(
                            postId: doc.id,
                            userId: currentUserId,
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
      ),
    );
  }
}
