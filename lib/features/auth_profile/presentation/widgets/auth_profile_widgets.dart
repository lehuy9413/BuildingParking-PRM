import 'package:flutter/material.dart';

class AuthProfileTag extends StatelessWidget {
  const AuthProfileTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}