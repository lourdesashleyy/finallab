import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  const EditProfilePage({super.key, required this.username});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? email, username, favoriteTeam, password, profilePictureUrl;
  bool isLoading = true;
  bool _isUpdating = false;
  late DocumentReference userDocRef;
  final List<String> teams = [
    'Barangay Ginebra San Miguel', 'San Miguel Beermen', 'TNT Tropang Giga',
    'Meralco Bolts', 'Magnolia Hotshots', 'Rain or Shine Elasto Painters',
    'Phoenix Super LPG Fuel Masters', 'NLEX Road Warriors',
    'NorthPort Batang Pier', 'Terrafirma Dyip', 'Blackwater Bossing',
    'Converge FiberXers'
  ];
  final picker = ImagePicker();
  File? _selectedImage;

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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> updateUserData() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isUpdating = true);
    String? uploadedUrl = profilePictureUrl;
    if (_selectedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref().child('profile_pictures/${widget.username}.jpg');
        await storageRef.putFile(_selectedImage!);
        uploadedUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print("Image upload failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed")),
        );
        setState(() => _isUpdating = false);
        return;
      }
    }

    try {
      await userDocRef.update({
        "email": email,
        "username": username,
        "favoriteTeam": favoriteTeam,
        "password": password,
        "profilePicture": uploadedUrl ?? '',
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
    setState(() => _isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF0D1B63);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white), // white font color
          ),
          backgroundColor: brandColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white), // for back button/icon color
        ),
        body: const Center(child: CircularProgressIndicator(color: brandColor)),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Edit Profile"),
            backgroundColor: brandColor,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: brandColor.withOpacity(0.1),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (profilePictureUrl != null && profilePictureUrl!.isNotEmpty)
                              ? NetworkImage(profilePictureUrl!) as ImageProvider
                              : const AssetImage("assets/profile_icon.jpg"),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Tap the picture to change",
                      style: TextStyle(
                        color: brandColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email field
                  TextFormField(
                    initialValue: email,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: brandColor),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: brandColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: brandColor.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (val) => email = val?.trim(),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Email is required";
                      if (!val.contains('@')) return "Invalid email";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Username field
                  TextFormField(
                    initialValue: username,
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(color: brandColor),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: brandColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: brandColor.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSaved: (val) => username = val?.trim(),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Username is required";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Favorite team dropdown
                  DropdownButtonFormField<String>(
                    value: favoriteTeam!.isNotEmpty ? favoriteTeam : null,
                    decoration: InputDecoration(
                      labelText: "Favorite Team",
                      labelStyle: TextStyle(color: brandColor),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: brandColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: brandColor.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: teams
                        .map((team) => DropdownMenuItem(value: team, child: Text(team)))
                        .toList(),
                    onChanged: (val) => setState(() => favoriteTeam = val),
                    onSaved: (val) => favoriteTeam = val,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please select a favorite team";
                      }
                      return null;
                    },
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  TextFormField(
                    initialValue: password,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: brandColor),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: brandColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: brandColor.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    obscureText: true,
                    onSaved: (val) => password = val?.trim(),
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // white font color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isUpdating)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
