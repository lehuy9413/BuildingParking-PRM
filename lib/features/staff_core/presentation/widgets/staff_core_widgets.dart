import 'package:flutter/material.dart';

class StaffCoreBadge extends StatelessWidget {
  const StaffCoreBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}