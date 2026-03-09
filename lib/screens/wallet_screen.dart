import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_session.dart';
import '../services/firestore_service.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = UserSession.uid!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("My Wallet"),
        backgroundColor: Colors.green,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// USER CARD
              StreamBuilder<DocumentSnapshot>(
                stream: FirestoreService().getUser(uid),

                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade400],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: const [
                            Icon(Icons.eco, color: Colors.white70, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Eco Credits",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "${data['credits'] ?? 0} pts",
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Welcome back,",
                          style: TextStyle(color: Colors.white70),
                        ),

                        Text(
                          data['name'] ?? "User",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              /// TITLE
              Text("Transaction History", style: theme.textTheme.titleMedium),

              const SizedBox(height: 15),

              /// TRANSACTIONS
              StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().getTransactions(uid),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "No Transactions Yet 🌱",
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemCount: snapshot.data!.docs.length,

                    itemBuilder: (context, i) {
                      final txn = snapshot.data!.docs[i];

                      final int points = txn['points'];

                      return transactionTile(
                        context: context,
                        title: txn['title'],
                        date: txn['date'],
                        points: points,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TRANSACTION TILE
  Widget transactionTile({
    required BuildContext context,
    required String title,
    required String date,
    required int points,
  }) {
    final theme = Theme.of(context);

    final Color color = points > 0 ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: theme.cardColor,

        borderRadius: BorderRadius.circular(18),

        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),

            child: Icon(Icons.eco, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
              ],
            ),
          ),

          Text(
            points > 0 ? "+$points" : "$points",

            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
