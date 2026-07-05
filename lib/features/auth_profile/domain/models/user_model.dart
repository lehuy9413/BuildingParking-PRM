class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}
