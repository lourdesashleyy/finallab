import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finallab_santosla/editprofile.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:finallab_santosla/screens/create_post_screen.dart';
import 'package:finallab_santosla/screens/edit_post_screen.dart';
import 'package:finallab_santosla/screens/comment_screen.dart';
import 'package:finallab_santosla/widgets/post_card.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final String currentUsername;
  const HomePage({super.key, required this.userId, required this.currentUsername});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;

  Future<void> _refreshPosts() async {
    setState(() {}); // triggers rebuild
  }

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
      if (!snapshot.exists) throw Exception("Post does not exist");
      final data = snapshot.data()!;
      final currentLikes = data['likes_count'] ?? 0;
      final likedUserIds = List<String>.from(data['likedUserIds'] ?? []);
      if (likedUserIds.contains(currentUserId)) {
        transaction.update(postRef, {
          'likes_count': currentLikes > 0 ? currentLikes - 1 : 0,
          'likedUserIds': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
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

  Widget buildShimmer() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 150,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildPostList(QuerySnapshot snapshot) {
    final docs = snapshot.docs;
    return ListView.separated(
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final formattedDate = "${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
        final isLiked = (data['likedUserIds'] as List<dynamic>?)?.contains(widget.userId) ?? false;

        return FutureBuilder<String>(
          future: getUsername(data['user_id']),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();
            return FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0).animate(_controller..forward()),
              child: PostCard(
                postId: doc.id,
                userId: data['user_id'],
                teamName: userSnap.data!,
                timeAgo: formattedDate,
                content: data['content'],
                imageUrl: data['image_url'],
                likes: data['likes_count'],
                comments: data['comments_count'],
                isOwner: data['user_id'] == widget.userId,
                currentUsername: widget.currentUsername,
                isLiked: isLiked,
                onLike: () => toggleLike(doc.id, widget.userId),
                onComment: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentScreen(postId: doc.id, userId: widget.userId),
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
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('tbl_Users').doc(widget.userId).get(),
              builder: (context, snapshot) {
                String profilePicUrl = '';
                String usernameDisplay = widget.currentUsername;
                String emailDisplay = '';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  profilePicUrl = data['profilePicture'] ?? '';
                  usernameDisplay = data['username'] ?? widget.currentUsername;
                  emailDisplay = data['email'] ?? '';
                }

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF0D1B63)),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : const AssetImage("assets/profile_icon.jpg") as ImageProvider,
                  ),
                  accountName: Text(usernameDisplay, style: const TextStyle(fontSize: 18)),
                  accountEmail: Text(emailDisplay.isNotEmpty ? emailDisplay : "No Email Found", style: const TextStyle(fontSize: 14)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      userId: widget.userId,
                      currentUsername: widget.currentUsername,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () async {
                Navigator.pop(context);
                String username = await getUsername(widget.userId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(username: username),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B63),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D1B63),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreatePostScreen(userId: widget.userId)),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: StreamBuilder<QuerySnapshot>(
            stream: getPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildShimmer();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No posts yet.\nPull down to refresh or add a new post."),
                );
              }

              return buildPostList(snapshot.data!);
            },
          ),
        ),
      ),
    );
  }
}
