import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class PendingShopService {
  static const String base = "http://192.168.159.43:5000/api/pending";

  Future<List<dynamic>> getPendingShops() async {
  final url = Uri.parse("$base/all");

  final res = await http.get(
    url,
    headers: {
      "Authorization": "Bearer ${AuthService.token}",
    },
  );

  final data = jsonDecode(res.body);

  if (data["status"] == "success") {
    return data["shops"];  // <---- THIS IS THE FIX
  }

  return [];
}

  Future<bool> approveShop(String id) async {
    final res = await http.post(
      Uri.parse("$base/approve/$id"),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    return res.statusCode == 200;
  }

  Future<bool> rejectShop(String id) async {
    final res = await http.delete(
      Uri.parse("$base/reject/$id"),
      headers: {"Authorization": "Bearer ${AuthService.token}"},
    );

    return res.statusCode == 200;
  }
}
