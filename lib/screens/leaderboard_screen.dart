import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("🏆 Leaderboard"),
        backgroundColor: Colors.green,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,

            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;

              final String name = data['name'] ?? "User";

              final int credits = (data['credits'] ?? 0) as int;

              final bool isCurrentUser = doc.id == currentUserId;

              return leaderboardTile(
                context: context,
                rank: index + 1,
                name: name,
                credits: credits,
                highlight: isCurrentUser,
              );
            },
          );
        },
      ),
    );
  }

  // 🔹 Rank Tile
  Widget leaderboardTile({
    required BuildContext context,
    required int rank,
    required String name,
    required int credits,
    required bool highlight,
  }) {
    final theme = Theme.of(context);

    Color rankColor;
    IconData? crownIcon;

    if (rank == 1) {
      rankColor = Colors.amber;
      crownIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey;
      crownIcon = Icons.workspace_premium;
    } else if (rank == 3) {
      rankColor = Colors.brown;
      crownIcon = Icons.military_tech;
    } else {
      rankColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: highlight ? Colors.green.withOpacity(0.15) : theme.cardColor,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],

        border: highlight ? Border.all(color: Colors.green, width: 1.5) : null,
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: rankColor.withOpacity(0.2),

            child: Text(
              "#$rank",
              style: TextStyle(color: rankColor, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(width: 14),

          if (crownIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(crownIcon, color: rankColor),
            ),

          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: highlight ? Colors.green : theme.colorScheme.onSurface,
              ),
            ),
          ),

          Text(
            "$credits pts",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
