import 'package:flutter/material.dart';
import 'profile.dart';

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFF0D1B63),
        actions: [
          IconButton(
            onPressed: () {
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
      body: Center(
        child: Text(
          "Welcome, $username!",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
