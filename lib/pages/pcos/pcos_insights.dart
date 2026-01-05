import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class PCOSScreen extends StatefulWidget {
  const PCOSScreen({super.key});

  @override
  State<PCOSScreen> createState() => _PCOSScreenState();
}

class _PCOSScreenState extends State<PCOSScreen> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? analysis;

  // Parameters we track for showing reasons
  bool irregular = false;
  bool weightGain = false;
  bool? acne;
  bool? hairGrowth;
  bool? skinDarkening;

  int cycleLength = 0;
  double variability = 0;
  double bmi = 0;

  @override
  void initState() {
    super.initState();
    fetchDeepAnalysis();
  }

  // ----------------------------------------
  // STD DEV (Cycle Variability)
  // ----------------------------------------
  double stdDev(List<int> values) {
    if (values.length < 2) return 0;

    double mean = values.reduce((a, b) => a + b) / values.length;

    double sumSq = values
        .map((v) => pow(v - mean, 2).toDouble())
        .reduce((a, b) => a + b);

    return sqrt(sumSq / values.length);
  }

  // ----------------------------------------
  // Convert Python generate_explanation() → Dart
  // ----------------------------------------
  String generateExplanation(Map<String, dynamic> payload, int cycleLength) {
    List<String> reasons = [];

    if (payload["irregular_periods"] == true) {
      reasons.add("Your cycle pattern suggests irregular ovulation.");
    }
    if (payload["weight_gain"] == true) {
      reasons.add("Your BMI indicates possible weight-related hormonal imbalance.");
    }
    if (payload["excess_hair_growth"] == true && hairGrowth != null) {
      reasons.add("You reported excess hair growth, a common PCOS sign.");
    }
    if (payload["acne"] == true && acne != null) {
      reasons.add("Your acne symptoms suggest elevated androgen levels.");
    }
    if (payload["dark_skin_patches"] == true && skinDarkening != null) {
      reasons.add("Skin darkening can indicate insulin resistance.");
    }
    if (cycleLength > 35) {
      reasons.add("Your average cycle length is longer than normal.");
    }

    if (reasons.isEmpty) {
      return "Your symptoms suggest a low likelihood of PCOS.";
    }

    return reasons.map((e) => "• $e").join("\n\n");
  }

  // ----------------------------------------
  // FETCH FIRESTORE + API + GENERATE EXPLANATION
  // ----------------------------------------
  Future<void> fetchDeepAnalysis() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (!doc.exists) throw "User data missing.";

      final data = doc.data()!;
      print("🔥 FIRESTORE DATA → $data");

      final rawHeight = data["height"];
      final rawWeight = data["weight"];
      final rawCycleLength = data["cycleLength"];
      final rawPeriods = data["periods"];
      final rawSymptoms = data["symptoms"] ?? [];

      if (rawHeight == null ||
          rawWeight == null ||
          rawCycleLength == null ||
          rawPeriods == null) {
        throw "Missing required fields.";
      }

      final double height = (rawHeight as num).toDouble();
      final double weight = (rawWeight as num).toDouble();
      cycleLength = (rawCycleLength as num).toInt();

      final List<DateTime> periods =
      rawPeriods.map<DateTime>((e) => (e as Timestamp).toDate()).toList();

      // BMI
      final double h = height / 100;
      bmi = weight / (h * h);
      weightGain = bmi >= 26;

      // SYMPTOMS (optional)
      if (rawSymptoms.isNotEmpty) {
        final last = rawSymptoms.last;

        acne = last["acne"];
        hairGrowth = last["hair_growth"];
        skinDarkening = last["skin_darkening"];
      } else {
        acne = null;
        hairGrowth = null;
        skinDarkening = null;
      }

      // CYCLE VARIABILITY
      List<int> diffs = [];
      for (int i = 1; i < periods.length; i++) {
        diffs.add(periods[i].difference(periods[i - 1]).inDays);
      }

      variability = stdDev(diffs);
      irregular = variability >= 4 || diffs.any((d) => d < 24 || d > 35);

      // API Body
      final apiBody = {
        "irregular_periods": irregular,
        "weight_gain": weightGain,
        "excess_hair_growth": hairGrowth ?? false,
        "acne": acne ?? false,
        "family_history": false,
        "dark_skin_patches": skinDarkening ?? false,
        "cycle_length_avg": cycleLength,
      };

      print("📤 API BODY → $apiBody");

      final response = await http.post(
        Uri.parse("https://web-production-34a40.up.railway.app/pcos/risk-assessment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(apiBody),
      );

      print("📥 API RESPONSE → ${response.body}");

      if (response.statusCode != 200) {
        throw "API error: ${response.statusCode}";
      }

      analysis = jsonDecode(response.body);

      setState(() => loading = false);
    } catch (e) {
      print("❌ ERROR → $e");
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // ----------------------------------------
  // UI BOX COMPONENT
  // ----------------------------------------
  Widget infoBox(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: color, fontSize: 16)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // ----------------------------------------
  // Helper to Display Symptom
  // ----------------------------------------
  String symptomText(bool? v) {
    if (v == null) return "Not Provided";
    return v ? "Present" : "Not Present";
  }

  // ----------------------------------------
  // UI LAYOUT
  // ----------------------------------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("PCOS Analysis")),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final risk = analysis?["risk_level"] ?? "Unknown";
    final score = (analysis?["risk_score"] ?? 0).toDouble();

    // Probability = score%
    final String prob = "${score.toStringAsFixed(1)}%";

    final explanation = generateExplanation({
      "irregular_periods": irregular,
      "weight_gain": weightGain,
      "excess_hair_growth": hairGrowth ?? false,
      "acne": acne ?? false,
      "dark_skin_patches": skinDarkening ?? false,
    }, cycleLength);

    Color riskColor = risk == "High"
        ? Colors.red
        : risk == "Moderate"
        ? Colors.orange
        : Colors.green;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PCOS Analysis"),
        elevation: 0,
        backgroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Lottie.asset("assets/illustration/confusewomen.json", height: 180),

            const SizedBox(height: 20),

            Chip(
              label: Text("Risk Level: $risk"),
              labelStyle: TextStyle(color: riskColor, fontSize: 18),
              backgroundColor: riskColor.withOpacity(0.2),
            ),

            const SizedBox(height: 20),

            infoBox("Risk Score", "$score / 100", Colors.deepPurple),
            infoBox("Probability", prob, Colors.blue),

            infoBox("Explanation", explanation, Colors.green),

            const SizedBox(height: 20),

            infoBox(
                "Cycle Irregularity",
                irregular
                    ? "Cycles show irregular patterns"
                    : "Cycles appear normal",
                Colors.orange),

            infoBox("Cycle Length", "$cycleLength days", Colors.teal),

            infoBox("Cycle Variability",
                "${variability.toStringAsFixed(1)} days", Colors.indigo),

            infoBox("BMI", bmi.toStringAsFixed(1), Colors.purple),

            infoBox("Weight Gain Indicator",
                weightGain ? "BMI suggests possible imbalance" : "Normal BMI",
                Colors.brown),

            infoBox("Acne", symptomText(acne), Colors.pink),
            infoBox("Excess Hair Growth", symptomText(hairGrowth), Colors.deepOrange),
            infoBox("Skin Darkening", symptomText(skinDarkening), Colors.grey),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
