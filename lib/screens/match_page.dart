import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/exif_helper.dart';
import '../services/log_service.dart';
import '../services/auth_service.dart';
import '../models/log_model.dart';

class MatchPage extends StatefulWidget {
  final dynamic shop;
  const MatchPage({super.key, required this.shop});

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  final LogService logService = LogService();
  bool processing = false;

  String? previewImageBase64;
  double? photoLat;
  double? photoLng;
  double? distanceDiff;

  /// DISTANCE FUNCTION
  double calcDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;

    return 12742 * asin(sqrt(a)); // in KM
  }

  /// SAVE LOG TO BACKEND
  Future<void> saveLog(String result) async {
    final user = AuthService.currentUser!;
    DateTime now = DateTime.now();

    LogModel log = LogModel(
      id: now.millisecondsSinceEpoch.toString(),
      userId: user["userId"].toString(),
      userName: user["name"].toString(),
      shopId: widget.shop["shopId"].toString(),
      shopName: widget.shop["shopName"].toString(),
      date: "${now.day}-${now.month}-${now.year}",
      time: "${now.hour}:${now.minute}:${now.second}",
      lat: widget.shop["lat"].toString(),
      lng: widget.shop["lng"].toString(),
      distance: distanceDiff?.toStringAsFixed(3) ?? "0",
      result: result,
      segment: widget.shop["segment"].toString(),
    );

    /// EXTRA FIELDS FOR BACKEND (BASE64 + GPS)
    Map<String, dynamic> json = log.toJson();
    json["photo_lat"] = photoLat;
    json["photo_lng"] = photoLng;
    json["photo_base64"] = previewImageBase64 ?? "";

    bool ok = await logService.addLog(json);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Log Saved ($result)" : "Save Failed"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    Navigator.pop(context);
  }

  /// CAPTURE + MATCH
  Future<void> captureAndMatch() async {
    setState(() => processing = true);

    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.camera);

    if (img == null) {
      setState(() => processing = false);
      return;
    }

    // Convert to BASE64
    final bytes = await img.readAsBytes();
    previewImageBase64 = base64Encode(bytes);

    // Extract EXIF GPS
    final gps = ExifHelper.extractGPS(bytes);
    photoLat = gps["lat"];
    photoLng = gps["lng"];

    if (photoLat == null || photoLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No GPS found in this photo!"),
            backgroundColor: Colors.red),
      );
      setState(() => processing = false);
      return;
    }

    double shopLat = double.parse(widget.shop["lat"].toString());
    double shopLng = double.parse(widget.shop["lng"].toString());

    distanceDiff = calcDistance(shopLat, shopLng, photoLat!, photoLng!);

    String result = distanceDiff! < 0.05 ? "Match" : "Mismatch";

    await saveLog(result);

    setState(() => processing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007BFF),
              Color(0xFF66B2FF),
              Color(0xFFB8E0FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Match Shop",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // SHOP DETAILS CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(widget.shop["shopName"],
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),

                            const SizedBox(height: 6),
                            Text(widget.shop["address"] ?? "",
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PHOTO PREVIEW
                      if (previewImageBase64 != null) ...[
                        Container(
                          height: 260,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: MemoryImage(
                                  base64Decode(previewImageBase64!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Distance Display
                        if (distanceDiff != null)
                          Text(
                            "Distance Difference: ${(distanceDiff! * 1000).toStringAsFixed(1)} meters",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),

                        const SizedBox(height: 20),

                        // Google Maps Preview
                        Container(
                          height: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                "https://maps.googleapis.com/maps/api/staticmap"
                                "?center=${widget.shop["lat"]},${widget.shop["lng"]}"
                                "&zoom=17"
                                "&size=600x300"
                                "&markers=color:red%7C${widget.shop["lat"]},${widget.shop["lng"]}"
                                "&key=YOUR_GOOGLE_MAPS_API_KEY",
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // MATCH BUTTON
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: processing ? null : captureAndMatch,
                          label: Text(
                            processing
                                ? "Processing..."
                                : "Capture & Match",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
