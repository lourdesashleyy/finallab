import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'posts_tab.dart';
import 'roster_tab.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String currentUsername;

  const ProfilePage({Key? key, required this.userId, required this.currentUsername}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> teamUsernames = [
    "ginebra_kings",
    "smb_beermen",
    "tnt_tropang",
    "meralco_energy",
    "magnolia_pambansang",
    "rainshine_elasto",
    "phoenix_lpg_masters",
    "nlex_roadmen",
    "northport_batang",
    "dyip_terrafirma",
    "bossing_blackwater",
    "fiberx_converge",
  ];

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

      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentLikes = data['likes_count'] ?? 0;
      final List<dynamic> likedUserIds = data['likedUserIds'] ?? [];

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tbl_Users')
          .doc(widget.userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User not found.")),
          );
        }

        final userData = userSnapshot.data!.data()! as Map<String, dynamic>;
        final username = userData['username'] ?? "";
        final followers = (userData['followers'] as List<dynamic>?) ?? [];
        final following = (userData['following'] as List<dynamic>?) ?? [];
        final profilePictureUrl = userData['profilePicture'] as String?;
        final isTeamAccount = teamUsernames.contains(username); // ✅ Correct check

        return DefaultTabController(
          length: isTeamAccount ? 2 : 1,
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
                    TabBar(
                      indicatorColor: const Color(0xFF0D1B63),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      tabs: [
                        const Tab(text: "POSTS"),
                        if (isTeamAccount) const Tab(text: "ROSTER"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          PostsTab(
                            userId: widget.userId,
                            currentUsername: widget.currentUsername,
                            getUsername: getUsername,
                            toggleLike: toggleLike,
                            deletePost: deletePost,
                          ),
                          if (isTeamAccount) RosterTab(username: username),
                        ],
                      ),
                    ),
                  ],
                ),
                // Top profile info
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
                      child: Stack(
                        children: [
                          Positioned(
                            top: 20,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF0D1B63), width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: profilePictureUrl != null
                                    ? NetworkImage(profilePictureUrl)
                                    : const AssetImage("assets/profile_icon.jpg")
                                as ImageProvider,
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
                                  username,
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
                                          "${followers.length}",
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
                                          "${following.length}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0D1B63)),
                                        ),
                                        const Text("Following", style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(width: 16),

                                    if (username != widget.currentUsername)
                                      FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('tbl_Users')
                                            .where('username', isEqualTo: widget.currentUsername)
                                            .limit(1)
                                            .get(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                            return const SizedBox();
                                          }

                                          final currentUserDoc = snapshot.data!.docs.first;
                                          final currentUserFollowing = (currentUserDoc['following'] as List<dynamic>?) ?? [];
                                          final isFollowing = currentUserFollowing.contains(username);

                                          return OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: Color(0xFF0D1B63)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              foregroundColor: const Color(0xFF0D1B63),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            ),
                                            onPressed: () async {
                                              final currentUserRef = currentUserDoc.reference;
                                              final viewedUserRef = FirebaseFirestore.instance
                                                  .collection('tbl_Users')
                                                  .doc(widget.userId);

                                              await FirebaseFirestore.instance.runTransaction((transaction) async {
                                                final currentUserSnap = await transaction.get(currentUserRef);
                                                final viewedUserSnap = await transaction.get(viewedUserRef);

                                                if (!currentUserSnap.exists || !viewedUserSnap.exists) return;

                                                final currentFollowing = List<String>.from(currentUserSnap['following'] ?? []);
                                                final viewedFollowers = List<String>.from(viewedUserSnap['followers'] ?? []);

                                                if (isFollowing) {
                                                  currentFollowing.remove(username);
                                                  viewedFollowers.remove(widget.currentUsername);
                                                } else {
                                                  currentFollowing.add(username);
                                                  viewedFollowers.add(widget.currentUsername);
                                                }

                                                transaction.update(currentUserRef, {'following': currentFollowing});
                                                transaction.update(viewedUserRef, {'followers': viewedFollowers});
                                              });

                                              setState(() {}); // Refresh UI
                                            },
                                            child: Text(isFollowing ? "UNFOLLOW" : "FOLLOW", style: const TextStyle(fontSize: 14)),
                                          );
                                        },
                                      )
                                    else
                                      const SizedBox(), // No button if self profile
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
