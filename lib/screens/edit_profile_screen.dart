import 'dart:typed_data';
import 'dart:io' show File;

import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final collegeController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();

  // Image
  Uint8List? webImage; // Web
  XFile? pickedImage; // Mobile
  final ImagePicker picker = ImagePicker();

  String department = "CSE";
  String photoUrl = "";

  bool loading = false;

  final List<String> departments = [
    "CSE",
    "IT",
    "ECE",
    "EEE",
    "CIVIL",
    "MECH",
    "AI & ML",
    "Data Science",
    "CSBS",
  ];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<User?> getUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      user = await FirebaseAuth.instance.authStateChanges().first;
    }

    return user;
  }

  // ================= LOAD PROFILE =================
  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User not logged in");
      return;
    }

    final uid = user.uid;

    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    final doc = await ref.get();

    // ✅ create doc if missing
    if (!doc.exists) {
      await ref.set({
        "name": "",
        "mobile": "",
        "collegeName": "",
        "department": department,
        "city": "",
        "address": "",
        "photoUrl": "",
        "role": "student",
        "credits": 0,
      });
    }

    final data = (await ref.get()).data()!;
    nameController.text = data['name'] ?? '';
    mobileController.text = data['mobile'] ?? '';
    collegeController.text = data['collegeName'] ?? '';
    cityController.text = data['city'] ?? '';
    addressController.text = data['address'] ?? '';
    department = data['department'] ?? department;
    photoUrl = data['photoUrl'] ?? "";

    setState(() {});
  }

  // ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    if (kIsWeb) {
      webImage = await image.readAsBytes();
    } else {
      pickedImage = image;
    }

    setState(() {});
  }

  // ================= SAVE PROFILE =================
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => loading = true);

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        user = await FirebaseAuth.instance.authStateChanges().first;
      }

      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      final uid = user.uid;
      String updatedPhotoUrl = photoUrl;

      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_photos")
          .child("$uid.jpg");

      // ✅ WEB IMAGE UPLOAD
      if (kIsWeb && webImage != null) {
        await ref.putData(webImage!);
        updatedPhotoUrl = await ref.getDownloadURL();
      }

      // ✅ MOBILE IMAGE UPLOAD
      if (!kIsWeb && pickedImage != null) {
        await ref.putFile(File(pickedImage!.path));
        updatedPhotoUrl = await ref.getDownloadURL();
      }

      // ✅ UPDATE FIRESTORE
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "name": nameController.text.trim(),
        "mobile": mobileController.text.trim(),
        "collegeName": collegeController.text.trim(),
        "department": department,
        "city": cityController.text.trim(),
        "address": addressController.text.trim(),
        "photoUrl": updatedPhotoUrl,
      });

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $e")));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.green.shade100,
                        backgroundImage: kIsWeb && webImage != null
                            ? MemoryImage(webImage!)
                            : (!kIsWeb && pickedImage != null)
                            ? FileImage(File(pickedImage!.path))
                            : (photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null)
                                  as ImageProvider?,
                        child:
                            (webImage == null &&
                                pickedImage == null &&
                                photoUrl.isEmpty)
                            ? const Icon(
                                Icons.camera_alt,
                                size: 30,
                                color: Colors.green,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _field(nameController, "Full Name"),
                    _field(mobileController, "Mobile Number"),
                    _field(collegeController, "College Name"),

                    DropdownButtonFormField(
                      value: department,
                      items: departments
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => department = v);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "Department",
                      ),
                    ),

                    const SizedBox(height: 10),

                    _field(cityController, "City"),
                    _field(addressController, "Address", maxLines: 3),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: saveProfile,
                        child: const Text("Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v!.isEmpty ? "$label required" : null,
      ),
    );
  }
}
