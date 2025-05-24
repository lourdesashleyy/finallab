import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  const EditProfilePage({super.key, required this.username});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String? email;
  String? username;
  String? favoriteTeam;
  String? password;
  String? profilePictureUrl;

  bool isLoading = true;
  late DocumentReference userDocRef;

  final TextEditingController _imageUrlController = TextEditingController();

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
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection("tbl_Users")
          .where("username", isEqualTo: widget.username)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        userDocRef = doc.reference;

        setState(() {
          email = data['email'] ?? "";
          username = data['username'] ?? "";
          favoriteTeam = data['favoriteTeam'] ?? "";
          password = data['password'] ?? "";
          profilePictureUrl = data['profilePicture'] ?? "";
          _imageUrlController.text = profilePictureUrl ?? "";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> updateUserData() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      await userDocRef.update({
        "email": email,
        "username": username,
        "favoriteTeam": favoriteTeam,
        "password": password,
        "profilePicture": profilePictureUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Edit Profile")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: (profilePictureUrl != null &&
                          profilePictureUrl!.isNotEmpty)
                          ? NetworkImage(profilePictureUrl!)
                          : const AssetImage("assets/profile_icon.jpg")
                      as ImageProvider,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration:
                      const InputDecoration(labelText: "Profile Picture URL"),
                      onChanged: (val) {
                        setState(() {
                          profilePictureUrl = val.trim();
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Profile picture URL is required";
                        }
                        return null;
                      },
                      onSaved: (val) => profilePictureUrl = val?.trim(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val?.trim(),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Email is required";
                  if (!val.contains('@')) return "Invalid email";
                  return null;
                },
              ),
              TextFormField(
                initialValue: username,
                decoration: const InputDecoration(labelText: "Username"),
                onSaved: (val) => username = val?.trim(),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Username is required";
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: favoriteTeam!.isNotEmpty ? favoriteTeam : null,
                decoration: const InputDecoration(labelText: "Favorite Team"),
                items: teams
                    .map((team) =>
                    DropdownMenuItem(value: team, child: Text(team)))
                    .toList(),
                onChanged: (val) => setState(() => favoriteTeam = val),
                onSaved: (val) => favoriteTeam = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Please select a favorite team";
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: password,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (val) => password = val?.trim(),
                validator: (val) {
                  if (val == null || val.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: updateUserData,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
