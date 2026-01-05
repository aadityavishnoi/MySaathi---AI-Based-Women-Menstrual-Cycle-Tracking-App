import 'package:flutter/material.dart';

class ThyroidParametersPage extends StatelessWidget {
  const ThyroidParametersPage({super.key});

  @override
  Widget build(BuildContext context) {
    const params = [
      "Unexplained Weight Gain",
      "Unexplained Weight Loss",
      "Constant Fatigue",
      "Cold Intolerance",
      "Heat Intolerance",
      "Hair Loss",
      "Dry Skin",
      "Neck Swelling (Goiter)",
      "Heart Palpitations",
      "Tremors",
      "Mood Changes",
      "Irregular Periods",
      "Family History of Thyroid Issues",
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff6f2ff),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Parameters Used"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "These symptoms and risk factors are used for thyroid prediction:",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          ...params.map(
                (p) => Container(
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Text("• $p",
                  style: const TextStyle(fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}
