import 'package:flutter/material.dart';

class StaffExceptionTag extends StatelessWidget {
  const StaffExceptionTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}