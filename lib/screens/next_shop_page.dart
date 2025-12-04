import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/location_helper.dart';
import '../models/shop_model.dart';
import '../services/assign_service.dart';
import '../services/auth_service.dart';

class NextShopPage extends StatefulWidget {
  const NextShopPage({super.key});

  @override
  State<NextShopPage> createState() => _NextShopPageState();
}

class _NextShopPageState extends State<NextShopPage> {
  final AssignService assignService = AssignService();

  ShopModel? nextShop;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadNextShop();
  }
  Future<void> loadNextShop() async {
  setState(() => loading = true);

  final user = AuthService.currentUser;
  if (user == null) {
    loading = false;
    setState(() {});
    return;
  }

  // 🔥 Step 1: Get current GPS using your helper
  final pos = await LocationHelper.getLocation();
  if (pos == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enable GPS to load next shop")),
    );
    loading = false;
    setState(() {});
    return;
  }

  double userLat = pos.latitude;
  double userLng = pos.longitude;

  final userId = user["user_id"].toString();

  // 🔥 Step 2: Pass GPS to backend
  final data =
      await assignService.getNextShop(userId, userLat, userLng);

  if (data != null) {
    nextShop = ShopModel.fromJson(data);
  } else {
    nextShop = null;
  }

  loading = false;
  setState(() {});
}

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final Uri url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
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
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BACK BUTTON + TITLE
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              size: 28, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Next Shop",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: nextShop == null
                          ? const Center(
                              child: Text(
                                "No shops assigned",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : _buildShopCard(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildShopCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Name
            Text(
              nextShop!.shopName,
              style: const TextStyle(
                color: Color(0xFF003366),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Address
            Text(
              nextShop!.address,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lat: ${nextShop!.lat},  Lng: ${nextShop!.lng}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // MAP BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _openGoogleMaps(nextShop!.lat, nextShop!.lng),
                icon: const Icon(Icons.navigation_rounded,
                    color: Colors.white),
                label: const Text(
                  "Open in Google Maps",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
