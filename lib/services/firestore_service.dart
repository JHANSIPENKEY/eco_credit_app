import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= USER =================

  Future<void> createUser(String uid, String name, String email) async {
    await _db.collection("users").doc(uid).set({
      "name": name,
      "email": email,
      "credits": 0,
      "rank": 0,
      "joined": DateTime.now().toString().substring(0, 10),
      "role": "student",
    });
  }

  Stream<DocumentSnapshot> getUser(String uid) {
    return _db.collection("users").doc(uid).snapshots();
  }

  // ================= WASTE HISTORY =================

  Stream<QuerySnapshot> getUserWasteHistory(String uid) {
    return _db
        .collection("users")
        .doc(uid)
        .collection("waste_logs")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Future<void> saveWasteRecord({
    required String uid,
    required String wasteType,
    required int credits,
  }) async {
    final userRef = _db.collection("users").doc(uid);

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw Exception("User not found");
      }

      int currentCredits = userSnapshot["credits"] ?? 0;

      // ✅ Update credits
      transaction.update(userRef, {"credits": currentCredits + credits});

      // ✅ Add waste log
      transaction.set(userRef.collection("waste_logs").doc(), {
        "wasteType": wasteType,
        "credits": credits,
        "timestamp": FieldValue.serverTimestamp(),
      });

      // ✅ Add transaction
      transaction.set(userRef.collection("transactions").doc(), {
        "title": "Waste Disposed: $wasteType",
        "points": credits,
        "type": "earn",
        "time": FieldValue.serverTimestamp(),
      });
    });
    await updateRanks();
  }

  // ================= TRANSACTIONS =================

  Stream<QuerySnapshot> getTransactions(String uid) {
    return _db
        .collection("users")
        .doc(uid)
        .collection("transactions")
        .orderBy("time", descending: true)
        .snapshots();
  }

  // ================= REWARDS =================

  Stream<QuerySnapshot> getRewards() {
    return _db
        .collection("rewards")
        .where("available", isEqualTo: true)
        .snapshots();
  }

  // ================= SAFE REDEEM =================

  Future<void> redeemReward(String uid, String rewardTitle, int cost) async {
    final userRef = _db.collection("users").doc(uid);

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);

      if (!userSnapshot.exists) {
        throw Exception("User not found");
      }

      int currentCredits = userSnapshot["credits"] ?? 0;

      if (currentCredits < cost) {
        throw Exception("Not enough credits");
      }

      // Deduct credits
      transaction.update(userRef, {"credits": currentCredits - cost});

      // Save redeem
      transaction.set(userRef.collection("redeems").doc(), {
        "rewardTitle": rewardTitle,
        "cost": cost,
        "time": FieldValue.serverTimestamp(),
      });

      // Add transaction record
      transaction.set(userRef.collection("transactions").doc(), {
        "title": rewardTitle,
        "points": -cost,
        "type": "redeem",
        "time": FieldValue.serverTimestamp(),
      });
    });
  }

  // ================= LEADERBOARD =================

  Stream<QuerySnapshot> getLeaderboard() {
    return _db
        .collection("users")
        .orderBy("credits", descending: true)
        .limit(10)
        .snapshots();
  }
  // ================= RANK SYSTEM =================

  Future<void> updateRanks() async {
    final usersSnapshot = await _db
        .collection("users")
        .orderBy("credits", descending: true)
        .get();

    int rank = 1;

    for (var doc in usersSnapshot.docs) {
      await doc.reference.update({"rank": rank});
      rank++;
    }
  }
  // ================= WEEKLY ANALYTICS =================

  Future<Map<String, int>> getWeeklyCredits(String uid) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final snapshot = await _db
        .collection("users")
        .doc(uid)
        .collection("waste_logs")
        .where("timestamp", isGreaterThan: Timestamp.fromDate(weekAgo))
        .get();

    Map<String, int> dailyTotals = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final Timestamp ts = data["timestamp"];
      final DateTime date = ts.toDate();

      String day = "${date.day}/${date.month}";
      int credits = data["credits"] ?? 0;

      dailyTotals[day] = (dailyTotals[day] ?? 0) + credits;
    }

    return dailyTotals;
  }
}
