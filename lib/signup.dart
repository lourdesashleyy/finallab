import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final securityQuestionController = TextEditingController();
  final securityAnswerController = TextEditingController();
  String? selectedTeam;

  final List<String> teams = [
    'Barangay Ginebra San Miguel',
    'San Miguel Beermen',
    'TNT Tropang Giga',
    'Meralco Bolts',
    'Magnolia Hotshots',
    'Rain or Shine Elasto Painters',
    'Phoenix Super LPG Fuel Masters',
    'NLEX Road Warriors',
    'NorthPort Batang Pier',
    'Terrafirma Dyip',
    'Blackwater Bossing',
    'Converge FiberXers',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/bg1.png', // Ensure this asset is available
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                ClipPath(
                  clipper: TopWaveClipper(),
                  child: Container(
                    height: 180,
                    color: const Color(0xFF0D1B63),
                    alignment: Alignment.center,
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField("Username", usernameController, icon: Icons.person),
                      _buildTextField("Email", emailController,
                          keyboardType: TextInputType.emailAddress, icon: Icons.email),
                      _buildTextField("Password", passwordController,
                          isPassword: true, icon: Icons.lock),
                      _buildTextField("Confirm Password", confirmPasswordController,
                          isPassword: true,
                          icon: Icons.lock_outline,
                          validator: (value) {
                            return value != passwordController.text
                                ? "Passwords do not match"
                                : null;
                          }),
                      _buildTextField("Security Question", securityQuestionController,
                          icon: Icons.question_answer),
                      _buildTextField("Security Answer", securityAnswerController,
                          icon: Icons.security),
                        DropdownButtonFormField<String>(
                          value: selectedTeam,
                          decoration: const InputDecoration(
                            labelText: "Favorite Team",
                            border: OutlineInputBorder(),
                          ),
                          items: teams.map((team) {
                            return DropdownMenuItem(
                              value: team,
                              child: Text(team),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTeam = value;
                            });
                          },
                          validator: (value) =>
                          value == null ? 'Please select a team' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D1B63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection("tbl_Users")
                                      .add({
                                    'username': usernameController.text,
                                    'email': emailController.text,
                                    'favoriteTeam': selectedTeam,
                                    'password': passwordController.text,
                                    'securityQuestion':
                                    securityQuestionController.text,
                                    'securityAnswer':
                                    securityAnswerController.text,
                                    'profilePicture': null,
                                  });

                                  Fluttertoast.showToast(
                                    msg: "Account successfully created",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginPage()),
                                  );
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: "Error: ${e.toString()}",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                }
                              }
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool isPassword = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
        IconData icon = Icons.person, // <-- Add default icon
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator ??
                (value) => value == null || value.isEmpty ? 'Enter $label' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF0D1B63)),
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFF0D1B63)),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0D1B63), width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0D1B63), width: 2),
          ),
        ),
      ),
    );
  }


}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
