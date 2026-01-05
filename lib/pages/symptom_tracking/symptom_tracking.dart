import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SymptomTrackingScreen extends StatefulWidget {
  const SymptomTrackingScreen({super.key});

  @override
  State<SymptomTrackingScreen> createState() => _SymptomTrackingScreenState();
}

class _SymptomTrackingScreenState extends State<SymptomTrackingScreen> {
  bool acne = false;
  bool hairGrowth = false;
  bool skinDarkening = false;
  bool moodSwings = false;
  bool weightGainFeeling = false;

  // ---------------- SAVE SYMPTOMS ----------------
  Future<void> saveSymptoms() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "symptoms": FieldValue.arrayUnion([
        {
          "date": DateTime.now(),
          "acne": acne,
          "hair_growth": hairGrowth,
          "skin_darkening": skinDarkening,
          "mood_swings": moodSwings,
          "weight_gain_feeling": weightGainFeeling,
        }
      ])
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Symptoms Saved!"))
    );

    Navigator.pop(context);
  }

  // ---------------- VIEW PAST SYMPTOMS POPUP ----------------
  void showPastSymptomsPopup() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();

    final List symptoms = doc.data()?["symptoms"] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 45,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const Text(
                    "Past Symptoms",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: symptoms.isEmpty
                        ? const Center(
                      child: Text(
                        "No past symptoms recorded.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      controller: controller,
                      itemCount: symptoms.length,
                      itemBuilder: (_, index) {
                        final s = symptoms[index];
                        final date = (s["date"] as Timestamp).toDate();
                        final formatted =
                            "${date.day}/${date.month}/${date.year}";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.purple.shade200, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatted,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 10),

                              symptomRow("Acne", s["acne"]),
                              symptomRow("Hair Growth", s["hair_growth"]),
                              symptomRow("Skin Darkening",
                                  s["skin_darkening"]),
                              symptomRow("Mood Swings",
                                  s["mood_swings"]),
                              symptomRow("Weight Gain Feeling",
                                  s["weight_gain_feeling"]),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- SYMPTOM ROW UI ----------------
  Widget symptomRow(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            "$title: ${value ? "Yes" : "No"}",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Symptoms"),
        actions: [
          IconButton(
            onPressed: showPastSymptomsPopup,
            icon: const Icon(Icons.history, size: 28),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showPastSymptomsPopup,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.visibility, color: Colors.white),
        label: const Text("View Past Symptoms", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            SwitchListTile(
              title: const Text("Excess Hair Growth"),
              value: hairGrowth,
              onChanged: (v) => setState(() => hairGrowth = v),
            ),

            SwitchListTile(
              title: const Text("Acne or Breakouts"),
              value: acne,
              onChanged: (v) => setState(() => acne = v),
            ),

            SwitchListTile(
              title: const Text("Dark Skin Patches"),
              value: skinDarkening,
              onChanged: (v) => setState(() => skinDarkening = v),
            ),

            SwitchListTile(
              title: const Text("Mood Swings"),
              value: moodSwings,
              onChanged: (v) => setState(() => moodSwings = v),
            ),

            SwitchListTile(
              title: const Text("Feeling of Weight Gain"),
              value: weightGainFeeling,
              onChanged: (v) => setState(() => weightGainFeeling = v),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: saveSymptoms,
              child: const Text("Save Symptoms"),
            ),
          ],
        ),
      ),
    );
  }
}
