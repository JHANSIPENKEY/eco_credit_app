import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WasteDisposalScreen extends StatelessWidget {
  WasteDisposalScreen({super.key});

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispose Waste"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Select Waste Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            wasteButton(
              context,
              title: "Organic Waste",
              credits: 10,
              color: Colors.green,
            ),

            wasteButton(
              context,
              title: "Recyclable Waste",
              credits: 15,
              color: Colors.blue,
            ),

            wasteButton(
              context,
              title: "Wrong Disposal",
              credits: -5,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Waste Button
  Widget wasteButton(
    BuildContext context, {
    required String title,
    required int credits,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "$title (${credits >= 0 ? '+' : ''}$credits Credits)",
          style: const TextStyle(fontSize: 15),
        ),
        onPressed: () async {
          await addEcoCredits(title, credits);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Credits Updated Successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  // 🔹 MAIN CREDIT FUNCTION
  Future<void> addEcoCredits(String category, int credits) async {
    final userRef = FirebaseFirestore.instance.collection("users").doc(uid);

    // 🔥 Atomic Increment (Better than manual fetch + update)
    await userRef.set({
      "credits": FieldValue.increment(credits),
    }, SetOptions(merge: true));

    // 🔹 Save Transaction Record
    await FirebaseFirestore.instance.collection("transactions").add({
      "userId": uid,
      "title": "Waste Disposed: $category",
      "points": credits,
      "date": Timestamp.now(),
    });

    // 🔹 Save Waste Log
    await FirebaseFirestore.instance.collection("waste_logs").add({
      "userId": uid,
      "category": category,
      "creditsEarned": credits,
      "timestamp": Timestamp.now(),
    });
  }
}
