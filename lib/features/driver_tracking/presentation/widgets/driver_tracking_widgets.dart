import 'package:flutter/material.dart';

class DriverTrackingTag extends StatelessWidget {
  const DriverTrackingTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}