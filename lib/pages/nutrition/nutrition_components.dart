import 'package:flutter/material.dart';

/// ----------------------------------------------------------
/// HERO BANNER
/// ----------------------------------------------------------
Widget nutritionHero({
  required String title,
  required String value,
  required Color color,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [color.withOpacity(0.9), color.withOpacity(0.55)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

/// ----------------------------------------------------------
/// MACRO CARD
/// ----------------------------------------------------------
Widget macroCard(String label, dynamic value, Color color) {
  final display = value?.toString() ?? "--";

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "$display g",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

/// ----------------------------------------------------------
/// SECTION TITLE
/// ----------------------------------------------------------
Widget sectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

/// ----------------------------------------------------------
/// INFO TILE
/// ----------------------------------------------------------
Widget infoTile(String title, String value) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(top: 10),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

/// ----------------------------------------------------------
/// SEVERITY BADGE FOR ALERTS
/// ----------------------------------------------------------
Widget severityBadge(String severity) {
  Color c;

  switch (severity.toLowerCase()) {
    case "high":
      c = Colors.red;
      break;
    case "medium":
      c = Colors.orange;
      break;
    case "low":
      c = Colors.green;
      break;
    default:
      c = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: c.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.7)),
    ),
    child: Text(
      severity.toUpperCase(),
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

/// ----------------------------------------------------------
/// BULLET POINT TEXT
/// ----------------------------------------------------------
Widget bulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 18)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    ),
  );
}

/// ----------------------------------------------------------
/// ALERT CARD (used in alerts list)
/// ----------------------------------------------------------
Widget alertCard({
  required String alertType,
  required String severity,
  required String message,
  required String recommendation,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Severity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                alertType,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            severityBadge(severity),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          message,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "Recommendation:",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          recommendation,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    ),
  );
}
