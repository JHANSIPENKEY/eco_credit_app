import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class WeeklyChartWidget extends StatefulWidget {
  const WeeklyChartWidget({super.key});

  @override
  State<WeeklyChartWidget> createState() => _WeeklyChartWidgetState();
}

class _WeeklyChartWidgetState extends State<WeeklyChartWidget> {
  Map<String, int> data = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      loadData();
    });
  }

  Future<void> loadData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User not logged in");
      setState(() => loading = false);
      return;
    }

    final uid = user.uid;

    final result = await FirestoreService().getWeeklyCredits(uid);

    if (!mounted) return;

    setState(() {
      data = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Text("No weekly data");
    }

    final entries = data.entries.toList();

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= entries.length) {
                    return const Text("");
                  }

                  return Text(
                    entries[value.toInt()].key,
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          barGroups: entries.asMap().entries.map((entry) {
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
    );
  }
}
