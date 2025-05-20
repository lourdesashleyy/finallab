import 'package:flutter/material.dart';
import 'profile.dart'; // Ensure this file exists and is linked properly

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/profile_icon.png'), // <- Your image path
              radius: 16,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text("Welcome to the Home Page!", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
