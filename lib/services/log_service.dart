import 'dart:convert';
import 'package:http/http.dart' as http;

class LogService {
  static const String baseUrl = "http://192.168.159.43:5000/api/logs";

  /// ADD LOG
  Future<bool> addLog(Map<String, dynamic> logData) async {
    try {
      final url = Uri.parse("$baseUrl/add");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(logData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Log Add Error: $e");
      return false;
    }
  }

  /// GET ALL LOGS
  Future<List<Map<String, dynamic>>> getLogsRaw() async {
    try {
      final url = Uri.parse("$baseUrl/all");
      final res = await http.get(url);

      if (res.statusCode != 200) return [];

      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    } catch (e) {
      print("Log Fetch Error: $e");
      return [];
    }
  }

  /// GET LOGS → converted for UI (used in log_history_page)
  Future<List<dynamic>> getLogs() async {
    try {
      final url = Uri.parse("$baseUrl/all");
      final res = await http.get(url);

      if (res.statusCode != 200) return [];

      return jsonDecode(res.body);
    } catch (e) {
      print("Error fetching logs: $e");
      return [];
    }
  }
}
