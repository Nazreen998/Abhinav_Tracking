import 'package:flutter/material.dart';
import '../services/shop_service.dart';
import '../models/shop_model.dart';

class ShopListPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const ShopListPage({super.key, required this.user});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage>
    with SingleTickerProviderStateMixin {
  final ShopService shopService = ShopService();

  List<ShopModel> shops = [];
  List<ShopModel> filteredShops = [];

  String searchQuery = "";
  bool loading = true;

  late AnimationController controller;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() => loading = true);

    final data = await shopService.getShops();
    shops = data;

    _applyRoleFilters();

    controller.forward(); // animation start
    setState(() => loading = false);
  }

  void _applyRoleFilters() {
    String role = widget.user["role"] ?? "";
    String segment = widget.user["segment"] ?? "";

    filteredShops = shops.where(
      (s) => s.segment.trim().toLowerCase() == segment.trim().toLowerCase()
).toList();

  }

  List<ShopModel> _searchFiltered() {
    return filteredShops.where((shop) {
      return shop.shopName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          shop.address.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Color _getSegmentColor(String segment) {
    switch (segment.toUpperCase()) {
      case "FMCG":
        return Colors.blue.shade800;
      case "PIPES":
        return Colors.orange.shade800;
      default:
        return Colors.purple.shade700;
    }
  }

  Color _getSegmentBG(String segment) {
    switch (segment.toUpperCase()) {
      case "FMCG":
        return Colors.blue.shade100;
      case "PIPES":
        return Colors.orange.shade100;
      default:
        return Colors.purple.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _searchFiltered();

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
              // BACK BUTTON + TITLE
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Shop List",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Search shops...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // SHOP LIST
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : result.isEmpty
                        ? const Center(
                            child: Text(
                              "No shops found",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : FadeTransition(
                            opacity: fadeAnim,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: result.length,
                              itemBuilder: (context, index) {
                                return _shopCard(result[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shopCard(ShopModel shop) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop Name
          Text(
            shop.shopName,
            style: const TextStyle(
              color: Color(0xFF003366),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // Address
          Text(
            shop.address,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          // SEGMENT BADGE
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getSegmentBG(shop.segment),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              shop.segment.toUpperCase(),
              style: TextStyle(
                color: _getSegmentColor(shop.segment),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
