import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://web-production-92013.up.railway.app";

  // ------------------------------
  // PREDICT CYCLE (FIXED DATA)
  // ------------------------------
  static Future<Map<String, dynamic>> predictCycle({
    required List<int> pastCycles,
    required DateTime lastPeriodDate,
  }) async {
    // Optional: delay to imitate real API call
    await Future.delayed(Duration(milliseconds: 300));

    // Return fixed offline data since server is down
    return {
      "predicted_cycle_length": 28,
      "predicted_next_period": "2025-02-12",
      "predicted_next_period_formatted": "Wednesday, February 12, 2025",
      "confidence_interval": {
        "predicted_days": 28,
        "min_days": 27,
        "max_days": 29,
        "earliest_date": "2025-02-11",
        "latest_date": "2025-02-13"
      },
      "statistics": {
        "average_cycle_length": 28.666666666666668,
        "std_deviation": 1.1785113019775793,
        "min_cycle": 27,
        "max_cycle": 31,
        "total_cycles_analyzed": 12
      },
      "uncertainty_days": 1.1785113019775793,
      "framework_used": "pytorch"
    };
  }
}
