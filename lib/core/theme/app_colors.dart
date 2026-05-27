import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — muted rose pink
  static const Color primary = Color(0xFFE8A0B0);
  static const Color primaryLight = Color(0xFFFCE4EC);
  static const Color primaryDark = Color(0xFFD4728A);
  static const Color primaryContainer = Color(0xFFFFF0F3);

  // Backgrounds
  static const Color background = Color(0xFFFAF8F9);
  static const Color backgroundSoftPink = Color(0xFFFDF0F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoftPink = Color(0xFFFFF5F7);
  static const Color surfaceVariant = Color(0xFFF5F0F2);

  // Text
  static const Color textPrimary = Color(0xFF2A2025);
  static const Color textSecondary = Color(0xFF9E8A90);
  static const Color textTertiary = Color(0xFFBFADB5);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Note card stack colors (pastel layers — top to bottom)
  static const List<Color> cardStack = [
    Color(0xFFFFFFFF),
    Color(0xFFFFF5F7),
    Color(0xFFFCECF0),
    Color(0xFFF9E0E8),
  ];

  // Cycle calendar colors
  static const Color periodFill = Color(0xFFEA9BAA);
  static const Color periodLight = Color(0xFFFCE4EC);
  static const Color fertileDay = Color(0xFFA8D8EA);
  static const Color fertileDayLight = Color(0xFFDDF3FB);
  static const Color ovulationDay = Color(0xFF6FC8E4);
  static const Color todayRing = Color(0xFFD47080);

  // UI
  static const Color divider = Color(0xFFF0E8EB);
  static const Color shadow = Color(0x149E8090);
  static const Color shadowStrong = Color(0x229E8090);
  static const Color inputFill = Color(0xFFF5F0F2);
  static const Color success = Color(0xFF9CBA9E);
  static const Color warning = Color(0xFFE8C4A0);

  // Bottom nav
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFFE8A0B0);
  static const Color navUnselected = Color(0xFFBFADB5);
}
