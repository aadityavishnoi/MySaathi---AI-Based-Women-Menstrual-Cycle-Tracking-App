import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'nutrition_calculate_page.dart';

class NutritionCalculateForm extends StatefulWidget {
  const NutritionCalculateForm({super.key});

  @override
  State<NutritionCalculateForm> createState() =>
      _NutritionCalculateFormState();
}

class _NutritionCalculateFormState extends State<NutritionCalculateForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController age = TextEditingController();
  TextEditingController height = TextEditingController();
  TextEditingController weight = TextEditingController();

  String activity = "moderate";       // default
  String goal = "weight_loss";        // default

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        age.text = (data["age"] ?? "").toString();
        height.text = (data["height"] ?? "").toString();
        weight.text = (data["weight"] ?? "").toString();
      }
    } catch (e) {
      debugPrint("Error loading user info: $e");
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Calculator"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              field("Age", age),
              field("Height (cm)", height),
              field("Weight (kg)", weight),

              const SizedBox(height: 16),
              dropdown(
                label: "Activity Level",
                value: activity,
                items: const [
                  "sedentary",
                  "light",
                  "moderate",
                  "active",
                  "very_active"
                ],
                onChanged: (v) => setState(() => activity = v!),
              ),

              const SizedBox(height: 16),
              dropdown(
                label: "Goal",
                value: goal,
                items: const ["weight_loss", "maintenance", "weight_gain"],
                onChanged: (v) => setState(() => goal = v!),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Get.to(() => NutritionCalculatePage(
                      age: int.parse(age.text),
                      height: int.parse(height.text),
                      weight: int.parse(weight.text),
                      activity: activity,
                      goal: goal,
                    ));
                  }
                },
                child: const Text(
                  "Calculate",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget field(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.isEmpty) return "Required";
          if (int.tryParse(v) == null) return "Enter a valid number";
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget dropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
            value: item,
            child: Text(item.replaceAll("_", " ").toUpperCase()),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
