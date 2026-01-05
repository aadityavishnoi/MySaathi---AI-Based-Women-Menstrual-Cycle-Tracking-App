import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'nutrition_alerts_page.dart';

class NutritionAlertForm extends StatefulWidget {
  const NutritionAlertForm({super.key});

  @override
  State<NutritionAlertForm> createState() => _NutritionAlertFormState();
}

class _NutritionAlertFormState extends State<NutritionAlertForm> {
  // SYMPTOMS
  double cramps = 1;
  double moodChanges = 1;
  double energy = 1;
  double bloating = 1;
  double headaches = 1;

  // LIFESTYLE
  double stress = 1;
  double exerciseIntensity = 1;
  double sleepQuality = 1;
  double weightChange = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Alerts Input"),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            section("Symptoms"),
            slider("Cramps", cramps, (v) => setState(() => cramps = v)),
            slider("Mood Changes", moodChanges, (v) => setState(() => moodChanges = v)),
            slider("Energy Level", energy, (v) => setState(() => energy = v)),
            slider("Bloating", bloating, (v) => setState(() => bloating = v)),
            slider("Headaches", headaches, (v) => setState(() => headaches = v)),

            const SizedBox(height: 20),
            section("Lifestyle"),

            slider("Stress Level", stress, (v) => setState(() => stress = v)),
            slider("Exercise Intensity", exerciseIntensity, (v) => setState(() => exerciseIntensity = v)),
            slider("Sleep Quality", sleepQuality, (v) => setState(() => sleepQuality = v)),

            weightSlider(),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              onPressed: () {
                Get.to(() => NutritionAlertsPage(
                  fromForm: true,
                  symptoms: {
                    "cramps": cramps.toInt(),
                    "mood_changes": moodChanges.toInt(),
                    "energy_level": energy.toInt(),
                    "bloating": bloating.toInt(),
                    "headaches": headaches.toInt(),
                  },
                  lifestyle: {
                    "stress_level": stress.toInt(),
                    "exercise_intensity": exerciseIntensity.toInt(),
                    "sleep_quality": sleepQuality.toInt(),
                    "weight_change": weightChange.toInt(),
                  },
                ));
              },
              child: const Text(
                "Generate Alerts",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // COMPONENTS
  // ---------------------------------------------------
  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget slider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toInt()}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Slider(
          value: value,
          min: 0,
          max: 5,
          divisions: 5,
          label: value.toInt().toString(),
          activeColor: Colors.orange.shade700,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget weightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Weight Change (kg): ${weightChange.toStringAsFixed(1)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Slider(
          value: weightChange,
          min: -5,
          max: 5,
          divisions: 10,
          label: weightChange.toStringAsFixed(1),
          activeColor: Colors.orange.shade700,
          onChanged: (v) => setState(() => weightChange = v),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
