import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'nutrition_components.dart';

class NutritionAlertsPage extends StatefulWidget {
  final bool fromForm;
  final Map<String, int>? symptoms;
  final Map<String, int>? lifestyle;

  const NutritionAlertsPage({
    super.key,
    this.fromForm = false,
    this.symptoms,
    this.lifestyle,
  });

  @override
  State<NutritionAlertsPage> createState() => _NutritionAlertsPageState();
}

class _NutritionAlertsPageState extends State<NutritionAlertsPage> {
  bool loading = true;
  List<dynamic> alerts = [];
  String? error;

  @override
  void initState() {
    super.initState();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await http.post(
        Uri.parse(
            "https://web-production-34a40.up.railway.app/nutrition/alerts"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "symptoms": widget.symptoms ??
              {
                "cramps": 1,
                "energy_level": 1,
                "bloating": 1,
                "mood_changes": 1,
                "headaches": 1,
              },
          "lifestyle": widget.lifestyle ??
              {
                "stress_level": 1,
                "exercise_intensity": 1,
                "sleep_quality": 1,
                "weight_change": 0,
              },
        }),
      );

      final decoded = jsonDecode(res.body);

      if (decoded is List) {
        alerts = decoded;
      } else {
        error = "Invalid response format.";
      }
    } catch (e) {
      error = e.toString();
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Alerts"),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAlerts,
          ),
        ],
      ),

      body: loading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.orange.shade700,
        ),
      )
          : error != null
          ? Center(
        child: Text(
          "Error: $error",
          style: const TextStyle(color: Colors.red),
        ),
      )
          : alerts.isEmpty
          ? const Center(
        child: Text(
          "No Alerts Found",
          style: TextStyle(fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            sectionTitle("Your Personalized Alerts"),

            const SizedBox(height: 12),

            ...alerts.map((alert) {
              return alertCard(
                alertType:
                alert["alert_type"] ?? "Unknown Alert",
                severity: alert["severity"] ?? "low",
                message: alert["message"] ?? "No message",
                recommendation:
                alert["recommendation"] ?? "No advice",
              );
            }).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
