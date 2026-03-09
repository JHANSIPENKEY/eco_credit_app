import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_session.dart';
import '../services/firestore_service.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = UserSession.uid!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Heading
              Text(
                "🎁 Rewards",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 6),

              Text(
                "Redeem your eco credits for exciting gifts",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              SizedBox(height: 20),

              // ✅ Wallet Balance Card
              StreamBuilder<DocumentSnapshot>(
                stream: FirestoreService().getUser(uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var userData = snapshot.data!.data() as Map<String, dynamic>;

                  return Container(
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Available Balance",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 6),

                            Text(
                              "${userData["credits"]} Credits",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        Icon(
                          Icons.account_balance_wallet,
                          size: 35,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 25),

              Text(
                "Available Rewards",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 15),

              // ✅ Dynamic Rewards From Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("rewards")
                    .where("available", isEqualTo: true)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var rewards = snapshot.data!.docs;

                  if (rewards.isEmpty) {
                    return Text("No rewards available ❌");
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: rewards.length,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.85,
                    ),

                    itemBuilder: (context, i) {
                      var reward = rewards[i];

                      return rewardCard(
                        context,
                        uid,
                        reward.id,
                        reward["title"],
                        reward["subtitle"],
                        reward["cost"],
                        reward["stock"],
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

  // ✅ Reward Card Widget
  Widget rewardCard(
    BuildContext context,
    String uid,
    String rewardId,
    String title,
    String subtitle,
    int cost,
    int stock,
  ) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.grey.shade200)],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.card_giftcard, size: 35, color: Colors.green),

          SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),

          SizedBox(height: 5),

          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey)),

          Spacer(),

          Text(
            "$cost credits",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.green,
            ),
          ),

          SizedBox(height: 4),

          Text(
            "Stock: $stock",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),

          SizedBox(height: 8),

          // ✅ Redeem Button
          SizedBox(
            height: 32,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: stock <= 0 ? Colors.grey : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              onPressed: stock <= 0
                  ? null
                  : () {
                      redeemPopup(context, uid, title, cost, rewardId);
                    },

              child: Text("Redeem", style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Redeem Popup
  void redeemPopup(
    BuildContext context,
    String uid,
    String title,
    int cost,
    String rewardId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Redeem"),
        content: Text("Redeem $title for $cost credits?"),

        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),

          ElevatedButton(
            child: Text("Redeem"),
            onPressed: () async {
              Navigator.pop(context);

              try {
                await FirestoreService().redeemReward(uid, title, cost);

                // ✅ Reduce Stock
                FirebaseFirestore.instance
                    .collection("rewards")
                    .doc(rewardId)
                    .update({"stock": FieldValue.increment(-1)});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Redeemed Successfully!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Not enough credits!")),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
