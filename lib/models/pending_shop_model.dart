class PendingShopModel {
  final String mongoId;
  final String shopId;
  final String shopName;
  final String address;
  final double lat;
  final double lng;
  final String createdBy;        // salesman name
  final String createdAt;        // date time
  final String segment;
  final String? imageBase64;

  PendingShopModel({
    required this.mongoId,
    required this.shopId,
    required this.shopName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.createdBy,
    required this.createdAt,
    required this.segment,
    this.imageBase64,
  });

  factory PendingShopModel.fromJson(Map<String, dynamic> json) {
    return PendingShopModel(
      mongoId: json["_id"] ?? "",
      shopId: json["shop_id"] ?? "",
      shopName: json["shop_name"] ?? "",
      address: json["address"] ?? "",
      lat: (json["lat"] ?? 0).toDouble(),
      lng: (json["lng"] ?? 0).toDouble(),
      createdBy: json["created_by_name"] ?? json["created_by"],
      createdAt: json["created_at"] ?? "",
      segment: json["segment"] ?? "",
       // ⭐ CHECK THESE IN ORDER
      imageBase64: json["image"] ??
                   json["shop_image"] ??
                   json["photo"] ??
                   json["img"] ??
                   null,
    );
  }
}
