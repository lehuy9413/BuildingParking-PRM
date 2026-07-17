import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  static TextTheme lightTextTheme = GoogleFonts.notoSansTextTheme(
    const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400),
    ),
  );

  static TextTheme darkTextTheme = GoogleFonts.notoSansTextTheme(
    const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
    ),
  );
}