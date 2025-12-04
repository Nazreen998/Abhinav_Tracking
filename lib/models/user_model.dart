class UserModel {
  final String? id;          // MongoDB _id (nullable)
  final String userId;       // always required
  final String name;
  final String mobile;
  final String role;
  final String password;
  final String createdAt;
  final String segment;

  UserModel({
    this.id,                 // ← now nullable (fixes error)
    required this.userId,
    required this.name,
    required this.mobile,
    required this.role,
    required this.password,
    required this.createdAt,
    required this.segment,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(),                 // can be null
      userId: json['user_id']?.toString() ?? "",
      name: json['name'] ?? "",
      mobile: json['mobile'] ?? "",
      role: json['role'] ?? "",
      password: json['password'] ?? "",
      createdAt: json['created_at'] ?? "",
      segment: json['segment'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "name": name,
      "mobile": mobile,
      "role": role,
      "password": password,
      "created_at": createdAt,
      "segment": segment,
    };
  }
}
