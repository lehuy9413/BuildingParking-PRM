import 'package:flutter/material.dart';

class VehicleIconHelper {
  static IconData getIconForVehicleType(String? typeName) {
    if (typeName == null) return Icons.directions_car_rounded;
    final n = typeName.toLowerCase();
    
    // Check for motorbike/two wheeler variants
    if (n.contains('motor') || n.contains('mô tô') || n.contains('mo to') || 
        n.contains('xe máy') || n.contains('xe may') || n.contains('bike')) {
      return Icons.two_wheeler_rounded;
    }
    
    // Check for electric variants
    if (n.contains('ev') || n.contains('electric') || n.contains('điện')) {
      return Icons.electric_car_rounded;
    }

    // Default to car
    return Icons.directions_car_rounded;
  }
}
