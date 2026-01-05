import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const BASE_URL = "https://web-production-106ba.up.railway.app";

class ThyroidFormPage extends StatefulWidget {
  const ThyroidFormPage({super.key});

  @override
  State<ThyroidFormPage> createState() => _ThyroidFormPageState();
}

class _ThyroidFormPageState extends State<ThyroidFormPage> {
  // Simplified user-friendly symptoms
  bool fatigue = false;
  bool sluggish = false;
  bool palpitations = false;
  bool cold = false;
  bool heat = false;
  bool hairLoss = false;
  bool drySkin = false;
  bool swelling = false;
  bool tremors = false;
  bool mood = false;
  bool irregular = false;
  bool weightGain = false;
  bool weightLoss = false;
  bool familyHistory = false;

  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Format date for backend (YYYY-MM-DD)
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // -----------------------------
    // ⭐ MAPPING simplified → API REQUIRED fields
    // -----------------------------
    final riskPayload = {
      "unexplained_weight_gain": weightGain,
      "unexplained_weight_loss": weightLoss,
      "constant_fatigue": (fatigue || sluggish),
      "cold_intolerance": cold,
      "heat_intolerance": heat,
      "hair_loss": hairLoss,
      "dry_skin": drySkin,
      "neck_swelling": swelling,
      "palpitations": palpitations,
      "tremors": tremors,
      "mood_changes": mood,
      "irregular_periods": irregular,
      "family_history": familyHistory,
    };

    // For analyze API → it requires an array with date + symptoms
    final analyzePayload = [
      {"date": formattedDate, ...riskPayload}
    ];

    try {
      // CALL ANALYZE API
      final analyzeRes = await http.post(
        Uri.parse("$BASE_URL/thyroid/analyze"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(analyzePayload),
      );

      // CALL RISK API
      final riskRes = await http.post(
        Uri.parse("$BASE_URL/thyroid/risk-assessment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(riskPayload),
      );

      final analyze = jsonDecode(analyzeRes.body);
      final risk = jsonDecode(riskRes.body);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("thyroidHistory")
          .add({
        "date": Timestamp.now(),
        "symptoms": riskPayload,
        "analysis": analyze,
        "riskAssessment": risk,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f2ff),
      appBar: AppBar(
        title: const Text("Thyroid Check-In"),
        backgroundColor: Colors.deepPurple,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Today's Symptoms",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 20),

          _card("General Symptoms", [
            _s("Fatigue", fatigue, (v) => setState(() => fatigue = v)),
            _s("Sluggishness", sluggish, (v) => setState(() => sluggish = v)),
            _s("Mood Changes", mood, (v) => setState(() => mood = v)),
          ]),

          const SizedBox(height: 16),

          _card("Temperature & Skin", [
            _s("Cold Sensitivity", cold, (v) => setState(() => cold = v)),
            _s("Heat Sensitivity", heat, (v) => setState(() => heat = v)),
            _s("Dry Skin", drySkin, (v) => setState(() => drySkin = v)),
            _s("Hair Loss", hairLoss, (v) => setState(() => hairLoss = v)),
          ]),

          const SizedBox(height: 16),

          _card("Body Indicators", [
            _s("Swelling / Neck Puffiness", swelling, (v) => setState(() => swelling = v)),
            _s("Palpitations", palpitations, (v) => setState(() => palpitations = v)),
            _s("Tremors", tremors, (v) => setState(() => tremors = v)),
          ]),

          const SizedBox(height: 16),

          _card("Reproductive & Weight", [
            _s("Irregular Periods", irregular, (v) => setState(() => irregular = v)),
            _s("Weight Gain", weightGain, (v) => setState(() => weightGain = v)),
            _s("Weight Loss", weightLoss, (v) => setState(() => weightLoss = v)),
          ]),

          const SizedBox(height: 16),

          _card("Medical Background", [
            _s("Family History (Thyroid)", familyHistory,
                    (v) => setState(() => familyHistory = v)),
          ]),

          const SizedBox(height: 28),

          loading
              ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
              : _submitBtn(),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              )),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _submitBtn() {
    return ElevatedButton(
      onPressed: submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        "Submit Symptoms",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _s(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.deepPurple,
      title: Text(label, style: const TextStyle(fontSize: 15)),
    );
  }
}
