import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw Exception("User document not found!");
    }

    return doc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
        future: loadUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data as Map<String, dynamic>;

          return _profileUI(context, data);
        },
      ),
    );
  }

  Widget _profileUI(BuildContext context, Map<String, dynamic> data) {
    final name = data["name"] ?? "Unknown";
    final email = data["email"] ?? "";
    final age = data["age"];
    final height = data["height"];
    final weight = data["weight"];
    final cycleLength = data["cycleLength"];
    final dob = data["dob"];
    final lastPeriod = (data["lastPeriodDate"] as Timestamp).toDate();
    final createdAt = (data["createdAt"] as Timestamp).toDate();
    final updatedAt = (data["updatedAt"] as Timestamp).toDate();
    final periodsCount = (data["periods"] as List).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ---------- PROFILE IMAGE ----------
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple,
            child: Icon(
              Icons.person_rounded,
              size: 55,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // ---------- NAME ----------
          Text(
            name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // ---------- EMAIL ----------
          Text(
            email,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          ),

          const SizedBox(height: 30),

          // ---------- INFO CARDS ----------
          _infoTile("Age", "$age years"),
          _infoTile("Date of Birth", dob),
          _infoTile("Height", "$height cm"),
          _infoTile("Weight", "$weight kg"),
          _infoTile("Cycle Length", "$cycleLength days"),
          _infoTile("Periods Recorded", "$periodsCount entries"),
          _infoTile("Last Period Date", lastPeriod.toString()),
          _infoTile("Account Created", createdAt.toString()),
          _infoTile("Last Updated", updatedAt.toString()),

          const SizedBox(height: 30),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
