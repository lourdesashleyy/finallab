import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController answerController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? securityQuestion;
  String? correctAnswer;
  bool showAnswerField = false;
  bool showAccountField = true;
  bool showResetPasswordFields = false;
  String? userId; // to hold document ID for updating

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final input = accountController.text.trim();
    setState(() => isLoading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection("tbl_Users")
          .where("email", isEqualTo: input)
          .get();

      final altQuery = await FirebaseFirestore.instance
          .collection("tbl_Users")
          .where("username", isEqualTo: input)
          .get();

      final docs = query.docs.isNotEmpty ? query.docs : altQuery.docs;

      if (docs.isEmpty) {
        Fluttertoast.showToast(msg: "No account found with that email or username.");
      } else {
        final userDoc = docs.first;
        final user = userDoc.data();
        setState(() {
          securityQuestion = user['securityQuestion'];
          correctAnswer = user['securityAnswer'].toString().toLowerCase().trim();
          userId = userDoc.id;
          showAnswerField = true;
          showAccountField = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }

    setState(() => isLoading = false);
  }

  void _verifyAnswer() {
    final userAnswer = answerController.text.trim().toLowerCase();
    if (userAnswer == correctAnswer) {
      Fluttertoast.showToast(msg: "Correct! You can now reset your password.");
      setState(() {
        showAnswerField = false;
        showResetPasswordFields = true;
      });
    } else {
      Fluttertoast.showToast(msg: "Incorrect answer. Please try again.");
    }
  }

  Future<void> _resetPassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "Passwords do not match.");
      return;
    }

    if (newPasswordController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("tbl_Users")
          .doc(userId)
          .update({"password": newPasswordController.text});

      Fluttertoast.showToast(msg: "Password updated successfully.");
      Navigator.pop(context); // go back to login or wherever
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update password: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: const Color(0xFF0D1B63),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/bg1.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0D1B63), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Forgot Your Password?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1B63),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Username/Email Input
                      if (showAccountField) ...[
                        TextFormField(
                          controller: accountController,
                          decoration: InputDecoration(
                            labelText: "Email or Username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email or username.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleForgotPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Submit",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],

                      // Security Question
                      if (showAnswerField && securityQuestion != null) ...[
                        Text(
                          "Security Question:",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1B63),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          securityQuestion!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: answerController,
                          decoration: InputDecoration(
                            labelText: "Your Answer",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your answer.";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _verifyAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Verify Answer",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],

                      // Password Reset Fields
                      if (showResetPasswordFields) ...[
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "New Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock_open),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Reset Password",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
