import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart'; // Assuming GetStartedPage is in main.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 5 seconds then navigate to GetStartedPage
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splashbg.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Image.asset(
              'assets/hnb_logo.png',
              width: 150, // Adjust as needed
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}
