import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ThyroidHistoryPage extends StatelessWidget {
  const ThyroidHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff6f2ff),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text("Thyroid History"),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("thyroidHistory")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No history available."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((d) {
              final data = d.data();
              final risk = data["riskAssessment"] ?? {};
              final analysis = data["analysis"] ?? {};

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                shadowColor: Colors.deepPurple.withOpacity(0.15),
                child: ListTile(
                  title: Text(
                      "Risk: ${risk["risk_level"] ?? "Unknown"}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "Condition: ${risk["condition_leaning"] ?? ""}\n"
                          "Status: ${analysis["status"] ?? ""}\n"
                          "Date: ${data["date"].toDate()}"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
