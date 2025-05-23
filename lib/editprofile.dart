import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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

  File? _pickedImageFile;
  bool _uploadingImage = false;

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

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
        _uploadingImage = true;
      });

      try {
        final uploadedUrl = await uploadImage(_pickedImageFile!);

        if (uploadedUrl != null) {
          await userDocRef.update({"profilePicture": uploadedUrl});

          setState(() {
            profilePictureUrl = uploadedUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image.")),
          );
        }
      } catch (e) {
        print("Error updating Firestore with image URL: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save profile picture.")),
        );
      } finally {
        setState(() => _uploadingImage = false);
      }
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = '${widget.username}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('profile_pictures').child(fileName);
      final uploadTask = await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
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
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _pickedImageFile != null
                              ? FileImage(_pickedImageFile!)
                              : (profilePictureUrl != null && profilePictureUrl!.isNotEmpty)
                              ? NetworkImage(profilePictureUrl!)
                              : const AssetImage("assets/profile_icon.jpg") as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_uploadingImage)
                      const CircularProgressIndicator(),
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
                items: teams.map((team) => DropdownMenuItem(value: team, child: Text(team))).toList(),
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
                onPressed: _uploadingImage ? null : updateUserData,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
