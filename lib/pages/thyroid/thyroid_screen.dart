import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'thyroid_form_page.dart';
import 'thyroid_history_page.dart';

class ThyroidScreen extends StatefulWidget {
  const ThyroidScreen({super.key});

  @override
  State<ThyroidScreen> createState() => _ThyroidScreenState();
}

class _ThyroidScreenState extends State<ThyroidScreen> {
  Map<String, dynamic>? latestEntry;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => isLoading = true);
    await _fetchLatest();
    setState(() => isLoading = false);
  }

  Future<void> _fetchLatest() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("thyroidHistory")
        .orderBy("date", descending: true)
        .limit(1)
        .get();

    latestEntry = snap.docs.isNotEmpty ? snap.docs.first.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    final risk = latestEntry?["riskAssessment"] ?? {};
    final analysis = latestEntry?["analysis"] ?? {};
    final symptoms = latestEntry?["symptoms"] ?? {};

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Thyroid Insights"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThyroidHistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        label: const Text("Add Check-in"),
        icon: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ThyroidFormPage()),
          );
          _refresh();
        },
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroHeader(risk),
              const SizedBox(height: 24),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (latestEntry == null)
                _emptyState()
              else
                _summaryCard(risk),

              if (!isLoading && latestEntry != null) ...[
                const SizedBox(height: 24),
                _detailedReport(risk, analysis, symptoms),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // HERO HEADER
  // --------------------------------------------------------------------------

  Widget _heroHeader(Map risk) {
    final riskLevel = (risk["risk_level"] ?? "Unknown").toString();
    final score = (risk["risk_score"] ?? 0);

    final Color color = switch (riskLevel.toLowerCase()) {
      "high" => Colors.red,
      "moderate" => Colors.orange,
      "low" => Colors.green,
      _ => Colors.grey,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color.withOpacity(0.4),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Latest Check-in",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            riskLevel.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Risk Score: $score",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------------------------------

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _card(),
      child: const Center(
        child: Text(
          "No thyroid records yet.\nTap “Add Check-in” to begin.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SUMMARY CARD
  // --------------------------------------------------------------------------

  Widget _summaryCard(Map risk) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Summary"),
          const SizedBox(height: 12),
          _infoRow("Condition", risk["condition_leaning"] ?? "N/A"),
          _infoRow("Matched Symptoms", "${risk["matched_symptoms"]?.length ?? 0}"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.deepPurple.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // DETAILED REPORT
  // --------------------------------------------------------------------------

  Widget _detailedReport(Map risk, Map analysis, Map symptoms) {
    final int score = risk["risk_score"] ?? 0;

    late String advice;
    late Color color;

    if (score <= 30) {
      advice = "You're safe. No doctor visit needed.";
      color = Colors.green;
    } else if (score <= 60) {
      advice = "Monitor symptoms. Doctor visit optional.";
      color = Colors.orange;
    } else if (score <= 100) {
      advice = "Doctor consultation recommended.";
      color = Colors.deepOrange;
    } else {
      advice = "URGENT: Consult a doctor immediately.";
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Consultation Advice"),
          const SizedBox(height: 10),
          _adviceBox(advice, color),
          const SizedBox(height: 20),

          _sectionTitle("Condition Details"),
          const SizedBox(height: 10),
          _bullet("Condition: ${risk["condition_leaning"]}"),
          _bullet("Risk Score: $score"),

          if (risk["matched_symptoms"] != null) ...[
            const SizedBox(height: 20),
            _sectionTitle("Matched Symptoms"),
            ...risk["matched_symptoms"]
                .map<Widget>((s) => _bullet(s))
                .toList(),
          ],

          if (analysis["insights"] != null &&
              analysis["insights"].isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionTitle("Insights"),
            const SizedBox(height: 10),
            ...analysis["insights"]
                .map<Widget>((s) => _insightCard(s))
                .toList(),
          ],

          const SizedBox(height: 20),
          _sectionTitle("Reported Symptoms"),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: symptoms.entries.map<Widget>((e) {
              final key = e.key.replaceAll("_", " ");
              final value = e.value.toString();
              return _symptomChip(key, value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // UI HELPERS
  // --------------------------------------------------------------------------

  BoxDecoration _card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        )
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        color: Colors.deepPurple.shade700,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _adviceBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // INSIGHT CARD
  Widget _insightCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.deepPurple.shade100,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded,
              color: Colors.deepPurple.shade400, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // SYMPTOM CHIP (NO TRUE/FALSE TEXT)
  // ------------------------------

  Widget _symptomChip(String key, String value) {
    final normalized = value.toString().trim().toLowerCase();

    late Color bg;
    late Color border;
    late Color textColor;

    if (normalized == "false") {
      bg = Colors.red.shade50;
      border = Colors.red.shade200;
      textColor = Colors.red.shade700;
    } else if (normalized == "true") {
      bg = Colors.green.shade50;
      border = Colors.green.shade200;
      textColor = Colors.green.shade700;
    } else {
      bg = Colors.deepPurple.shade50;
      border = Colors.deepPurple.shade100;
      textColor = Colors.deepPurple.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: textColor),
          const SizedBox(width: 8),
          Text(
            key.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18, height: 1.2)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          )
        ],
      ),
    );
  }
}
