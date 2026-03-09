import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'admin_dashboard.dart';
import 'main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 🔄 Checking login
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        final user = authSnapshot.data!;
        final uid = user.uid;

        // 🔍 Fetch user data
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // ⚠️ If user doc not created yet
            if (!userSnapshot.hasData ||
                !userSnapshot.data!.exists ||
                userSnapshot.data!.data() == null) {
              // create default user document
              FirebaseFirestore.instance.collection('users').doc(uid).set({
                "role": "student",
                "name": "",
                "credits": 0,
                "rank": 0,
              });

              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;

            final role = data['role'] ?? 'student';

            // 🚀 Role based navigation
            if (role == "admin") {
              return AdminDashboard();
            } else {
              return MainNavigation(role: role);
            }
          },
        );
      },
    );
  }
}
