import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'nutrition_components.dart';

class NutritionCalculatePage extends StatefulWidget {
  final int age;
  final int height;
  final int weight;
  final String activity;
  final String goal;

  const NutritionCalculatePage({
    super.key,
    required this.age,
    required this.height,
    required this.weight,
    required this.activity,
    required this.goal,
  });

  @override
  State<NutritionCalculatePage> createState() =>
      _NutritionCalculatePageState();
}

class _NutritionCalculatePageState extends State<NutritionCalculatePage> {
  bool loading = true;
  Map<String, dynamic>? data;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchNutrition();
  }

  Future<void> fetchNutrition() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await http.post(
        Uri.parse(
            "https://web-production-bb794.up.railway.app/nutrition/calculate"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "age": widget.age,
          "height": widget.height,
          "weight": widget.weight,
          "activity_level": widget.activity,
          "goal": widget.goal,
        }),
      );

      final decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      } else {
        error = "Invalid response format";
      }
    } catch (e) {
      error = e.toString();
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final calories = data?["calories"]?.toString() ?? "--";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Report"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchNutrition)
        ],
      ),

      body: loading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.green.shade700,
        ),
      )
          : error != null
          ? Center(
        child: Text(
          "Error: $error",
          style: const TextStyle(color: Colors.red),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HERO SECTION
            nutritionHero(
              title: "Recommended Calories",
              value: "$calories kcal",
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            sectionTitle("Macronutrients"),

            Row(
              children: [
                Expanded(
                  child: macroCard(
                    "Protein",
                    data?["protein"],
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: macroCard(
                    "Carbs",
                    data?["carbs"],
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: macroCard(
                    "Fats",
                    data?["fats"],
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: macroCard(
                    "Water (L)",
                    data?["water_intake"],
                    Colors.teal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            sectionTitle("BMI Analysis"),

            infoTile("BMI", (data?["bmi"] ?? "--").toString()),
            infoTile(
                "Category", data?["bmi_category"] ?? "Unknown"),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
