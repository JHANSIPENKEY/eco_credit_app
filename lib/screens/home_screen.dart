import '../services/user_session.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main_navigation.dart';
import 'edit_profile_screen.dart';
import 'splash_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  String? uid = UserSession.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String name = data['name'] ?? "User";
          final int credits = data['credits'] ?? 0;
          final int rank = data['rank'] ?? 0;
          final String role = data['role'] ?? "student";

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// GREETING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Welcome Eco Credit App 🌱",
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      /// PROFILE MENU
                      PopupMenuButton<String>(
                        icon: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.green.shade100,

                          child: Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        onSelected: (value) {
                          if (value == "profile") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MainNavigation(
                                  selectedIndex: 4,
                                  role: role,
                                ),
                              ),
                            );
                          }

                          if (value == "wallet") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MainNavigation(
                                  selectedIndex: 1,
                                  role: role,
                                ),
                              ),
                            );
                          }

                          if (value == "leaderboard") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MainNavigation(
                                  selectedIndex: 3,
                                  role: role,
                                ),
                              ),
                            );
                          }

                          if (value == "edit") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          }

                          if (value == "logout") {
                            FirebaseAuth.instance.signOut();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SplashScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },

                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "profile",
                            child: ListTile(
                              leading: Icon(Icons.person),
                              title: Text("My Profile"),
                            ),
                          ),
                          const PopupMenuItem(
                            value: "wallet",
                            child: ListTile(
                              leading: Icon(Icons.account_balance_wallet),
                              title: Text("Transaction History"),
                            ),
                          ),
                          const PopupMenuItem(
                            value: "leaderboard",
                            child: ListTile(
                              leading: Icon(Icons.emoji_events),
                              title: Text("Leaderboard"),
                            ),
                          ),
                          const PopupMenuItem(
                            value: "edit",
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text("Edit Profile"),
                            ),
                          ),
                          const PopupMenuItem(
                            value: "logout",
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text("Logout"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ECO CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade400],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "Eco Credits",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "$credits",
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const Text(
                          "pts",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "Rank #$rank",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
