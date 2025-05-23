import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finallab_santosla/signup.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'forgotpassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() => isLoading = true);

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection("tbl_Users")
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (query.docs.isNotEmpty) {
        final userDoc = query.docs.first;
        final userId = userDoc.id; // this is the document ID

        // Optional: Verify user_id field consistency
        await FirebaseFirestore.instance.collection("tbl_Users").doc(userId).update({
          'user_id': userId,
        });

        // Pass the document ID to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid username or password")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/bg1.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Top curved background
              Container(
                height: 240,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D1B63),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
              ),

              // "Login" text
              const Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Form and content below the curve
              Padding(
                padding: const EdgeInsets.only(top: 250),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Username
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextFormField(
                            controller: usernameController,
                            validator: (value) =>
                            value!.isEmpty ? 'Enter your username' : null,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Color(0xFF0D1B63)),
                              hintText: 'Username',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0D1B63), width: 2),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0D1B63), width: 2),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            validator: (value) =>
                            value!.isEmpty ? 'Enter your password' : null,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: Color(0xFF0D1B63)),
                              hintText: 'Password',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0D1B63), width: 2),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0D1B63), width: 2),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D1B63),
                                foregroundColor: Colors.white, // sets text/icon color to white
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 6,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                if (_formKey.currentState!.validate()) {
                                  loginUser();
                                }
                              },
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Signup and Forgot Password
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterForm()),
                                  );
                                },
                                child: const Text(
                                  "Don't have an Account? Sign Up.",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),


                        const SizedBox(height: 200),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
