import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/weekly_chart_widget.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'settings_screen.dart';
import 'admin_dashboard.dart';
import 'splash_screen.dart';
import '../services/user_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? uid = UserSession.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String name = data['name'] ?? "No Name";
          final String email = data['email'] ?? "No Email";
          final String collegeId = uid ?? "-";
          final String role = data['role'] ?? "student";
          final int credits = data['credits'] ?? 0;
          final String rank = data['rank'] != null ? "#${data['rank']}" : "-";
          final String joined = data['joined'] ?? "-";
          final String photoUrl = data['photoUrl'] ?? "";

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// ===== HEADER =====
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade400],
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl.isEmpty
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 10),

                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          email,
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  /// ===== BODY =====
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            stat(context, "Credits", credits.toString()),
                            stat(context, "Rank", rank),
                            stat(context, "Joined", joined),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Weekly Performance",
                            style: theme.textTheme.titleMedium,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const WeeklyChartWidget(),

                        const SizedBox(height: 30),

                        infoTile(context, "College ID", collegeId),
                        infoTile(context, "Email", email),

                        const SizedBox(height: 25),

                        tile(context, "Edit Profile", Icons.edit, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        }),

                        tile(context, "Change Password", Icons.lock, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangePasswordScreen(),
                            ),
                          );
                        }),

                        tile(context, "Settings", Icons.settings, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SettingsScreen()),
                          );
                        }),

                        if (role == 'admin')
                          tile(
                            context,
                            "Admin Dashboard",
                            Icons.admin_panel_settings,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminDashboard(),
                                ),
                              );
                            },
                          ),

                        tile(context, "Logout", Icons.logout, () async {
                          await FirebaseAuth.instance.signOut();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => SplashScreen()),
                            (route) => false,
                          );
                        }, color: Colors.red),
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

  /// ===== HELPERS =====

  Widget stat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget infoTile(BuildContext context, String title, String value) {
    return ListTile(title: Text(title), subtitle: Text(value));
  }

  Widget tile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: color ?? theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(color: color ?? theme.colorScheme.onSurface),
      ),
      onTap: onTap,
    );
  }
}
