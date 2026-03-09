import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class WeeklyChartScreen extends StatefulWidget {
  const WeeklyChartScreen({super.key});

  @override
  State<WeeklyChartScreen> createState() => _WeeklyChartScreenState();
}

class _WeeklyChartScreenState extends State<WeeklyChartScreen> {
  Map<String, int> data = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final result = await FirestoreService().getWeeklyCredits(uid);

    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Weekly Performance"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: data.isEmpty
            ? const Center(child: Text("No Data"))
            : BarChart(
                BarChartData(
                  barGroups: data.entries.toList().asMap().entries.map((entry) {
                    int index = entry.key;
                    int value = entry.value.value;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value.toDouble(),
                          color: Colors.green,
                          width: 16,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
