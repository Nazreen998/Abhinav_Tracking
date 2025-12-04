import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class VisitService {
  static const baseUrl = "http://192.168.159.43:5000/api/visit";

  /// Upload Base64 image to backend
  Future<String?> uploadPhoto(String base64, String filename) async {
    final res = await http.post(
      Uri.parse("$baseUrl/upload"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "image": base64,
        "filename": filename,
      }),
    );

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    return data["url"]; // returns image URL saved in cloud
  }

  /// SAVE VISIT LOG
  Future<bool> saveVisit(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse("$baseUrl/log"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    return res.statusCode == 200;
  }

  /// GET NEXT SHOP
  Future<Map<String, dynamic>?> getNextShop(String userId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/next/$userId"),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    if (res.statusCode != 200) return null;

    return jsonDecode(res.body)["shop"];
  }
}
