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
  final securityAnswerController = TextEditingController();
  String? selectedTeam;
  String? selectedSecurityQuestion;

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

  final List<String> securityQuestions = [
    "What is your mother's maiden name?",
    "What was the name of your first pet?",
    "What is your favorite movie?",
    "What is your hometown?",
    "What is your favorite food?",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/bg1.png',
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
                        _buildAccountSection(),
                        _buildSecuritySection(),
                        const SizedBox(height: 0),
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
                                  final newDocRef = FirebaseFirestore.instance
                                      .collection("tbl_Users")
                                      .doc(); // Generate ID
                                  await newDocRef.set({
                                    'user_id': newDocRef.id,
                                    'username': usernameController.text,
                                    'email': emailController.text,
                                    'favoriteTeam': selectedTeam,
                                    'password': passwordController.text,
                                    'securityQuestion': selectedSecurityQuestion,
                                    'securityAnswer': securityAnswerController.text,
                                    'profilePicture': null,
                                    'followers': [],
                                    'following': [],
                                  });

                                  Fluttertoast.showToast(
                                    msg: "Account successfully created",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
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

  Widget _buildAccountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 5),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Account Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B63),
            ),
          ),
          const SizedBox(height: 0),
          _buildTextField("Username", usernameController, icon: Icons.person),
          _buildTextField("Email", emailController,
              keyboardType: TextInputType.emailAddress, icon: Icons.email),
          _buildTextField("Password", passwordController,
              isPassword: true, icon: Icons.lock),
          _buildTextField("Confirm Password", confirmPasswordController,
              isPassword: true, icon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirm your password';
                if (value != passwordController.text) return 'Passwords do not match';
                return null;
              }),
          DropdownButtonFormField<String>(
            value: selectedTeam,
            decoration: _dropdownDecoration("Favorite Team"),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0D1B63)),
            style: const TextStyle(color: Color(0xFF0D1B63), fontSize: 16),
            items: teams.map((team) {
              return DropdownMenuItem(value: team, child: Text(team));
            }).toList(),
            onChanged: (value) => setState(() => selectedTeam = value),
            validator: (value) => value == null ? 'Please select a team' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16, bottom: 10),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Security Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B63),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedSecurityQuestion,
                  decoration: _dropdownDecoration("Security Question"),
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0D1B63)),
                  style: const TextStyle(color: Color(0xFF0D1B63), fontSize: 16),
                  items: securityQuestions.map((question) {
                    return DropdownMenuItem(
                      value: question,
                      child: Text(
                        question,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => selectedSecurityQuestion = value),
                  validator: (value) =>
                  value == null ? 'Please select a security question' : null,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildTextField("Security Answer", securityAnswerController, icon: Icons.security),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Color(0xFF0D1B63),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B63), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B63), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B63), width: 2.5),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF0D1B63), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool isPassword = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
        IconData icon = Icons.person,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator ?? (value) => value == null || value.isEmpty ? 'Enter $label' : null,
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
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
