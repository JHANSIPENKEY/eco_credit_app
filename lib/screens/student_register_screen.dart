import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  // Controllers
  final rollController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final collegeController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();

  // Dropdown / Radio values
  String countryCode = "+91";
  String gender = "Male";
  String department = "CSE";

  String day = "1";
  String month = "1";
  String year = "2000";

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

  // ================= REGISTER FUNCTION =================
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      // 1️⃣ Create Firebase Auth user
      final roll = rollController.text.trim();

      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: "$roll@aec.edu.in",
            password: roll,
          );
      final uid = cred.user!.uid;

      // 2️⃣ Upload photo (ONLY if selected)
      String photoUrl = "";

      if (selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("profile_photos")
            .child("$uid.jpg");

        await ref.putFile(selectedImage!);
        photoUrl = await ref.getDownloadURL();
      }

      // 3️⃣ SAVE USER DATA IN FIRESTORE  ✅⬅️ THIS IS WHERE
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "role": "student",
        "rollNo": rollController.text.trim(),
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "name":
            "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        "email": emailController.text.trim(),
        "dob": "$day-$month-$year",
        "mobile": "$countryCode ${mobileController.text.trim()}",
        "gender": gender,
        "collegeName": collegeController.text.trim(),
        "department": department,
        "city": cityController.text.trim(),
        "address": addressController.text.trim(),
        "credits": 0,
        "rank": 0,
        "joined": "Feb 2026",
        "photoUrl": photoUrl, // ✅ HERE
      });

      // 4️⃣ Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Student Registered Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }

    setState(() => loading = false);
  }

  //register form
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Registration"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _textField(rollController, "Roll Number"),
              _textField(firstNameController, "First Name"),
              _textField(lastNameController, "Last Name"),

              // DOB
              Row(
                children: [
                  _dobDropdown("Day", day, 31, (v) => setState(() => day = v)),
                  _dobDropdown(
                    "Month",
                    month,
                    12,
                    (v) => setState(() => month = v),
                  ),
                  _yearDropdown(),
                ],
              ),

              // Mobile
              Row(
                children: [
                  DropdownButton<String>(
                    value: countryCode,
                    items: ["+91", "+1", "+44"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => countryCode = v!),
                  ),
                  Expanded(
                    child: _textField(
                      mobileController,
                      "Mobile Number",
                      keyboard: TextInputType.phone,
                    ),
                  ),
                ],
              ),

              _emailField(),
              _passwordField(),

              // Gender
              Row(
                children: ["Male", "Female", "Other"].map((g) {
                  return Row(
                    children: [
                      Radio(
                        value: g,
                        groupValue: gender,
                        onChanged: (v) => setState(() => gender = v.toString()),
                      ),
                      Text(g),
                    ],
                  );
                }).toList(),
              ),

              _textField(collegeController, "College Name"),

              DropdownButtonFormField(
                initialValue: department,
                items: departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => department = v.toString()),
                decoration: InputDecoration(labelText: "Department"),
              ),

              SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text("Upload Student Photo"),
              ),

              _textField(cityController, "City"),
              _textField(addressController, "Address", maxLines: 3),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : submitForm,
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _textField(
    TextEditingController c,
    String label, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v!.isEmpty ? "$label required" : null,
      ),
    );
  }

  Widget _emailField() {
    return _textField(
      emailController,
      "Email",
      keyboard: TextInputType.emailAddress,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(labelText: "Password"),
      validator: (v) => v!.length < 8 ? "Min 8 characters" : null,
    );
  }

  Widget _dobDropdown(
    String label,
    String value,
    int count,
    Function(String) onChanged,
  ) {
    return Expanded(
      child: DropdownButtonFormField(
        initialValue: value,
        items: List.generate(
          count,
          (i) => DropdownMenuItem(value: "${i + 1}", child: Text("${i + 1}")),
        ),
        onChanged: (v) => onChanged(v.toString()),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _yearDropdown() {
    return Expanded(
      child: DropdownButtonFormField(
        initialValue: year,
        items: List.generate(
          30,
          (i) => DropdownMenuItem(
            value: "${1995 + i}",
            child: Text("${1995 + i}"),
          ),
        ),
        onChanged: (v) => setState(() => year = v.toString()),
        decoration: InputDecoration(labelText: "Year"),
      ),
    );
  }
}
