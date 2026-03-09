import 'package:flutter/material.dart';

class RewardCard extends StatelessWidget {
  final String title;
  final int credits;

  const RewardCard({super.key, required this.title, required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.grey.shade200)],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.card_giftcard, size: 35, color: Colors.green),

          SizedBox(height: 10),

          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),

          Spacer(),

          Text(
            "$credits credits",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {},
            child: Text("Redeem"),
          ),
        ],
      ),
    );
  }
}
