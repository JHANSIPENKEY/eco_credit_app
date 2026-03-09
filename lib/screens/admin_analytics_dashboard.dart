import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsDashboard extends StatelessWidget {
  const AdminAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text("📊 Admin Analytics Dashboard"),
        backgroundColor: Colors.green,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Dashboard Overview
            Text(
              "System Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // ✅ Total Users Count
            analyticsCard(
              title: "Total Students",
              icon: Icons.people,
              color: Colors.blue,
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .snapshots(),
            ),

            // ✅ Total Waste Disposals
            analyticsCard(
              title: "Total Waste Disposals",
              icon: Icons.delete,
              color: Colors.orange,
              stream: FirebaseFirestore.instance
                  .collection("waste_logs")
                  .snapshots(),
            ),

            // ✅ Total Rewards
            analyticsCard(
              title: "Total Rewards Available",
              icon: Icons.card_giftcard,
              color: Colors.purple,
              stream: FirebaseFirestore.instance
                  .collection("rewards")
                  .snapshots(),
            ),

            SizedBox(height: 30),

            // ✅ Smart Bin Status Section
            Text(
              "Smart Dustbin Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 15),

            smartBinCard(),
          ],
        ),
      ),
    );
  }

  // ✅ Analytics Card Widget (Counts Documents)
  Widget analyticsCard({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<QuerySnapshot> stream,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        int total = snapshot.data!.docs.length;

        return Container(
          margin: EdgeInsets.only(bottom: 15),
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),

              SizedBox(width: 15),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),

              Text(
                "$total",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Smart Bin Card Widget
  Widget smartBinCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("bins")
          .doc("bin01")
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var binData = snapshot.data!.data() as Map<String, dynamic>;

        return Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade400],
            ),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bin Location: ${binData["location"]}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "Fill Level: ${binData["fillLevel"]}%",
                style: TextStyle(color: Colors.white70),
              ),

              SizedBox(height: 8),

              Text(
                "Status: ${binData["status"]}",
                style: TextStyle(color: Colors.white70),
              ),

              SizedBox(height: 12),

              LinearProgressIndicator(
                value: binData["fillLevel"] / 100,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }
}
