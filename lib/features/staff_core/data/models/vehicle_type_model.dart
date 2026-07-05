/// Model đại diện cho loại xe trả về từ API.
class VehicleTypeModel {
  final String id;
  final String name;
  final String code;
  final String? icon;
  final double dayBlockRate;
  final double dailyRate;

  const VehicleTypeModel({
    required this.id,
    required this.name,
    required this.code,
    this.icon,
    required this.dayBlockRate,
    required this.dailyRate,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] ?? {};
    return VehicleTypeModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      icon: json['icon']?.toString(),
      dayBlockRate: (pricing['dayBlockRate'] ?? 0).toDouble(),
      dailyRate: (pricing['dailyRate'] ?? 0).toDouble(),
    );
  }
}
