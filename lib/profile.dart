import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('tbl_users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data()!.containsKey('username')) {
          setState(() {
            username = doc['username'];
          });
        } else {
          setState(() {
            username = "No Username";
          });
        }
      }
    } catch (e) {
      setState(() {
        username = "Error";
      });
      debugPrint("Failed to fetch username: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: const Color(0xFF0D1B63),
        ),
        body: Stack(
          children: [
            // Background banner
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
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      Container(
                        color: Colors.white.withOpacity(0.8),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white.withOpacity(0.9),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Team Name 1", style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    const Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit...", style: TextStyle(fontSize: 14)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: const [
                                        Icon(Icons.favorite_border, size: 16),
                                        SizedBox(width: 4),
                                        Text("15"),
                                        SizedBox(width: 12),
                                        Icon(Icons.chat_bubble_outline, size: 16),
                                        SizedBox(width: 4),
                                        Text("9"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Profile Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/profile_banner.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF0D1B63), width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/profile_icon.jpg"),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: 120,
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B63),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 65,
                    left: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Column(
                          children: [
                            Text("300", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1B63))),
                            Text("Followers", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          children: [
                            Text("100", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1B63))),
                            Text("Following", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0D1B63)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            foregroundColor: const Color(0xFF0D1B63),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("EDIT", style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}