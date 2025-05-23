import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'editprofile.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int followerCount = 0;
  int followingCount = 0;
  String? profilePictureUrl;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection("tbl_Users")
          .where("username", isEqualTo: widget.username)
          .get();

      if (query.docs.isNotEmpty) {
        final userDoc = query.docs.first;
        final data = userDoc.data();

        setState(() {
          userId = userDoc.id;
          followerCount = (data['followers'] as List?)?.length ?? 0;
          followingCount = (data['following'] as List?)?.length ?? 0;
          profilePictureUrl = data['profilePicture'] as String?;
        });
      }
    } catch (e) {
      print("Error fetching user stats: $e");
    }
  }

  Stream<QuerySnapshot> getUserPosts() {
    if (userId == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection("tbl_posts")
        .where("userId", isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: const Color(0xFF0D1B63),
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/profile_banner.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 180),
                const TabBar(
                  indicatorColor: Color(0xFF0D1B63),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(text: "POSTS"),
                    Tab(text: "ROSTER"),
                  ],
                ),

                Expanded(
                  child: TabBarView(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: getUserPosts(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final posts = snapshot.data!.docs;

                          if (posts.isEmpty) {
                            return const Center(child: Text("No posts yet."));
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index].data() as Map<String, dynamic>;
                              return Card(
                                color: Colors.white.withOpacity(0.9),
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post["team"] ?? "Team Name",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        post["content"] ?? "",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.favorite_border, size: 16),
                                          const SizedBox(width: 4),
                                          Text("${post["likes"] ?? 0}"),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.chat_bubble_outline, size: 16),
                                          const SizedBox(width: 4),
                                          Text("${post["comments"] ?? 0}"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      Container(
                        color: Colors.transparent,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Roster content here",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/profile_banner.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                  child: userId != null
                      ? StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tbl_Users')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final liveUsername = data['username'] ?? '';
                      final liveProfilePictureUrl = data['profilePicture'];

                      return Stack(
                        children: [
                          Positioned(
                            top: 20,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFF0D1B63), width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: liveProfilePictureUrl != null
                                    ? NetworkImage(liveProfilePictureUrl)
                                    : const AssetImage("assets/profile_icon.jpg") as ImageProvider,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  liveUsername,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D1B63),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Row(
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "$followerCount",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0D1B63)),
                                        ),
                                        const Text("Followers", style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          "$followingCount",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0D1B63)),
                                        ),
                                        const Text("Following", style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFF0D1B63)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30)),
                                        foregroundColor: const Color(0xFF0D1B63),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      ),
                                      onPressed: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfilePage(username: widget.username),
                                          ),
                                        );
                                        if (updated == true) {
                                          fetchUserStats(); // refresh
                                        }
                                      },
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text("EDIT", style: TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}