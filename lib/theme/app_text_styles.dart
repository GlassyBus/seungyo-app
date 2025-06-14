import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'KBO';

  static const double _letterSpacing2 = -0.02;
  static const double _letterSpacing3 = -0.03;

  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: _letterSpacing2,
    fontFamily: fontFamily,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: _letterSpacing2,
    fontFamily: fontFamily,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: _letterSpacing2,
    fontFamily: fontFamily,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: _letterSpacing2,
    fontFamily: fontFamily,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: fontFamily,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: fontFamily,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: fontFamily,
  );

  static const TextStyle body3 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: fontFamily,
  );

  static const TextStyle button1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: fontFamily,
  );

  static const TextStyle button2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: fontFamily,
  );

  // === Common aliases for convenience ===
  static const TextStyle titleLarge = h1;
  static const TextStyle titleMedium = h2;
  static const TextStyle titleSmall = h3;
  static const TextStyle bodyLarge = body1;
  static const TextStyle bodyMedium = body2;
  static const TextStyle bodySmall = caption;
}
