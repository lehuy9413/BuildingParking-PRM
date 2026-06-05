import 'package:flutter/material.dart';

class DriverBookingTag extends StatelessWidget {
  const DriverBookingTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}