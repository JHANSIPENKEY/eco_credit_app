import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRewardScreen extends StatefulWidget {
  const AddRewardScreen({super.key});

  @override
  State<AddRewardScreen> createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final costController = TextEditingController();
  final stockController = TextEditingController();

  Future addReward() async {
    await FirebaseFirestore.instance.collection("rewards").add({
      "title": titleController.text.trim(),
      "subtitle": subtitleController.text.trim(),
      "cost": int.parse(costController.text.trim()),
      "stock": int.parse(stockController.text.trim()),
      "available": true,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Reward Added Successfully ✅")));

    titleController.clear();
    subtitleController.clear();
    costController.clear();
    stockController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Reward"), backgroundColor: Colors.green),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Reward Title"),
            ),

            TextField(
              controller: subtitleController,
              decoration: InputDecoration(labelText: "Reward Subtitle"),
            ),

            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Cost Credits"),
            ),

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Stock"),
            ),

            SizedBox(height: 20),

            ElevatedButton(onPressed: addReward, child: Text("Add Reward")),
          ],
        ),
      ),
    );
  }
}
