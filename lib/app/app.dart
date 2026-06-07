import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'view/home_screen.dart';
export 'view/home_screen.dart' show HomeScreen;
import '../features/auth_profile/presentation/screens/auth_profile_screen.dart';

class SmartParkingApp extends StatefulWidget {
  const SmartParkingApp({super.key});

  static SmartParkingAppState of(BuildContext context) => 
      context.findAncestorStateOfType<SmartParkingAppState>()!;

  @override
  State<SmartParkingApp> createState() => SmartParkingAppState();
}

class SmartParkingAppState extends State<SmartParkingApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool currentIsDark) {
    setState(() {
      _themeMode = currentIsDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Parking Mobile App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const AuthProfileScreen(),
    );
  }
}