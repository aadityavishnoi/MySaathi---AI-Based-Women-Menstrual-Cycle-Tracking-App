import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MockAppointmentScreen extends StatefulWidget {
  const MockAppointmentScreen({super.key});

  @override
  State<MockAppointmentScreen> createState() => _MockAppointmentScreenState();
}

class _MockAppointmentScreenState extends State<MockAppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8A2BE2),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hourMinuteColor: Colors.deepPurple.shade50,
              dialHandColor: Colors.deepPurple,
              dialBackgroundColor: Colors.deepPurple.shade100,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) setState(() => selectedTime = time);
  }

  void _confirmBooking() {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose both date and time.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Appointment booked (Mock)!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? "Choose a date"
        : DateFormat("EEEE, MMM d, yyyy").format(selectedDate!);

    final timeText = selectedTime == null
        ? "Choose a time"
        : selectedTime!.format(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),

      // BEAUTIFUL GRADIENT HEADER
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
          ),
        ),
        title: Row(
          children: const [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.calendar_month, color: Colors.deepPurple),
            ),
            SizedBox(width: 12),
            Text(
              "Book Appointment",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // DATE CARD
            GestureDetector(
              onTap: _pickDate,
              child: _selectionCard(
                title: "Select Date",
                value: dateText,
                icon: Icons.calendar_today_rounded,
                color: Colors.deepPurple.shade100,
              ),
            ),

            const SizedBox(height: 20),

            // TIME CARD
            GestureDetector(
              onTap: _pickTime,
              child: _selectionCard(
                title: "Select Time",
                value: timeText,
                icon: Icons.access_time_filled_rounded,
                color: Colors.purple.shade100,
              ),
            ),

            const Spacer(),

            // CONFIRM BUTTON
            GestureDetector(
              onTap: _confirmBooking,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A2BE2), Color(0xFFB279FF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Confirm Appointment",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // MODULAR CARD UI WIDGET
  Widget _selectionCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      color: value.contains("Choose") ? Colors.grey : Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
