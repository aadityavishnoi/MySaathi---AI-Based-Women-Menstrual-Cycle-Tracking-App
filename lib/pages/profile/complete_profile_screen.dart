import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final cycleLengthController = TextEditingController();

  DateTime? lastPeriodDate;

  // MUST BE 5 dates → gives 4 cycles
  List<DateTime?> periodDates = [null, null, null, null, null];

  bool saving = false;

  pickDate(Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) onSelected(picked);
  }

  saveProfile() async {
    if (ageController.text.isEmpty ||
        cycleLengthController.text.isEmpty ||
        lastPeriodDate == null ||
        periodDates.any((d) => d == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => saving = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() => saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    try {
      // ⭐ FIX: Sort dates: oldest → newest
      periodDates.sort((a, b) => a!.compareTo(b!));

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "age": int.parse(ageController.text),
        "height": heightController.text.isNotEmpty
            ? int.parse(heightController.text)
            : null,
        "weight": weightController.text.isNotEmpty
            ? int.parse(weightController.text)
            : null,
        "cycleLength": int.parse(cycleLengthController.text),

        "lastPeriodDate": Timestamp.fromDate(lastPeriodDate!),

        "periods": periodDates.map((e) => Timestamp.fromDate(e!)).toList(),

        "profileCompleted": true,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            inputField("Age", ageController, number: true),
            inputField("Height (cm) - optional", heightController, number: true),
            inputField("Weight (kg) - optional", weightController, number: true),
            inputField("Cycle Length (days)", cycleLengthController,
                number: true),

            const SizedBox(height: 20),

            const Text("Last Period Date:", style: TextStyle(fontSize: 16)),
            ListTile(
              title: Text(lastPeriodDate == null
                  ? "Select date"
                  : lastPeriodDate.toString().substring(0, 10)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () =>
                  pickDate((picked) => setState(() => lastPeriodDate = picked)),
            ),

            const SizedBox(height: 20),

            const Text("Last 5 Period Dates:", style: TextStyle(fontSize: 16)),
            for (int i = 0; i < 5; i++)
              ListTile(
                title: Text(
                  periodDates[i] == null
                      ? "Select Date ${i + 1}"
                      : periodDates[i]!.toString().substring(0, 10),
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () =>
                    pickDate((picked) => setState(() => periodDates[i] = picked)),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save & Continue",
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inputField(String label, TextEditingController controller,
      {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
