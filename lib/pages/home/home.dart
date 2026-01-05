import 'package:codebloom/doctor/mock_appointment_screen.dart';
import 'package:codebloom/doctor/mock_doctor_chat_screen.dart';
import 'package:codebloom/pages/ai_chatbot/mysaathi.dart';
import 'package:codebloom/pages/pcos/pcos_insights.dart';
import 'package:codebloom/pages/symptom_tracking/symptom_tracking.dart';
import 'package:codebloom/pages/thyroid/thyroid_screen.dart';
import 'package:codebloom/pages/nutrition/nutrition_calculate_form.dart';
import 'package:codebloom/pages/nutrition/nutrition_alert_form.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../services/api_service.dart';
import '../profile/profile_screen.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>> loadUserAndPredict() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final data = doc.data()!;
    final periods = (data["periods"] as List).map((e) => (e as Timestamp).toDate()).toList();
    periods.sort((a, b) => a.compareTo(b));
    final List<int> pastCycles = [];
    for (int i = 1; i < periods.length; i++) {
      final diff = periods[i].difference(periods[i - 1]).inDays;
      if (diff >= 20 && diff <= 45) pastCycles.add(diff);
    }
    final prediction = await ApiService.predictCycle(
      pastCycles: pastCycles,
      lastPeriodDate: periods.last,
    );
    return {
      "name": data["name"] ?? "User",
      "cycleLength": prediction["predicted_cycle_length"],
      "nextPeriod": prediction["predicted_next_period_formatted"],
      "minDays": prediction["confidence_interval"]["min_days"],
      "maxDays": prediction["confidence_interval"]["max_days"],
      "average": prediction["statistics"]["average_cycle_length"],
      "uncertainty": prediction["uncertainty_days"],
    };
  }

  Future<void> generatePDF({
    required context,
    required String name,
    required cycleLength,
    required nextPeriod,
    required minDays,
    required maxDays,
    required avg,
    required uncertainty,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context ctx) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("CodeBloom Cycle Report",
                  style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Generated on: ${DateTime.now()}"),
              pw.SizedBox(height: 20),
              pw.Text("Name: $name", style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 12),
              pw.Text("Predicted Cycle Length: $cycleLength days",
                  style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text("Next Period: $nextPeriod", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text("Range: $minDays – $maxDays days",
                  style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text("Average Cycle: $avg days", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text("Uncertainty: ±${uncertainty.toStringAsFixed(1)} days",
                  style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 40),
              pw.Text("Thank you for using CodeBloom.",
                  style: pw.TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDoctorSheet(context),
        icon: const Icon(Icons.health_and_safety_rounded, color: Colors.white),
        label: const Text("Consult Doctor",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "CodeBloom",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        actions: [
          FutureBuilder(
            future: loadUserAndPredict(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              final d = snapshot.data!;
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
                onPressed: () {
                  generatePDF(
                    context: context,
                    name: d["name"],
                    cycleLength: d["cycleLength"],
                    nextPeriod: d["nextPeriod"],
                    minDays: d["minDays"],
                    maxDays: d["maxDays"],
                    avg: d["average"],
                    uncertainty: d["uncertainty"],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadUserAndPredict(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            );
          }
          final data = snapshot.data!;
          return _ui(
            context,
            data["name"],
            data["cycleLength"],
            data["nextPeriod"],
            data["minDays"],
            data["maxDays"],
            data["average"],
            data["uncertainty"],
          );
        },
      ),
    );
  }

  Widget _ui(context, name, cycleLength, nextPeriod, minDays, maxDays, avg, uncertainty) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Get.to(() => const ProfileScreen()),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person_2_rounded, size: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hey $name 👋",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Here are your predicted cycle insights:",
                      style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Predicted Cycle Length: $cycleLength days",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                Text("Next Period: $nextPeriod",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                Text("Range: $minDays – $maxDays days",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                Text("Average Cycle: $avg days",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                Text("Uncertainty: ±${uncertainty.toStringAsFixed(1)} days",
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _purpleButton(
            label: "Talk To My Saathi!",
            onTap: () => Get.to(() => SaathiChatScreen()),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _featureCard(
                title: "PCOS Insights",
                color: Colors.purple.shade50,
                animation: 'assets/illustration/confusewomen.json',
                onTap: () => Get.to(() => PCOSScreen()),
              )),
              const SizedBox(width: 16),
              Expanded(child: _featureCard(
                title: "Symptom Tracking",
                color: Colors.pink.shade50,
                animation: 'assets/illustration/Woman.json',
                onTap: () => Get.to(() => SymptomTrackingScreen()),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _featureCard(
                title: "Thyroid Insights",
                color: Colors.blue.shade50,
                animation: 'assets/illustration/TiredWoman.json',
                onTap: () => Get.to(() => const ThyroidScreen()),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _featureCard(
                title: "Nutrition Insights",
                color: Colors.green.shade50,
                animation: 'assets/illustration/Ketodiagram.json',
                onTap: () => _showNutritionSheet(context),
              )),
            ],
          ),
        ],
      ),
    );
  }

  void _showNutritionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _grabber(),
              const Text("Nutrition Insights 🥗",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _sheetOption(
                icon: Icons.calculate_rounded,
                title: "Nutrition Calculator",
                subtitle: "Find calories & macro requirements",
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const NutritionCalculateForm());
                },
              ),
              const SizedBox(height: 12),
              _sheetOption(
                icon: Icons.health_and_safety_rounded,
                title: "Nutrition Alerts",
                subtitle: "Check symptoms & recommendations",
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const NutritionAlertForm());
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDoctorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _grabber(),
              const Text("Consult With a Doctor 👩‍⚕️",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _sheetOption(
                icon: Icons.chat_bubble_outline,
                title: "Chat With Gynecologist",
                subtitle: "Ask health questions instantly",
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const MockDoctorChatScreen());
                },
              ),
              const SizedBox(height: 12),
              _sheetOption(
                icon: Icons.calendar_month,
                title: "Book Appointment",
                subtitle: "Visit a doctor at your convenience",
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const MockAppointmentScreen());
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _grabber() {
    return Container(
      height: 4,
      width: 40,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _purpleButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _featureCard({
    required String title,
    required Color color,
    required String animation,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Lottie.asset(animation, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.deepPurple, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
