import 'package:flutter/material.dart';

const double _letterSpacing2 = -0.02;
const double _letterSpacing3 = -0.03;

TextTheme appTextTheme = TextTheme(
  displayLarge: TextStyle(
    // H1
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: _letterSpacing2,
    fontFamily: 'KBO',
  ),
  displayMedium: TextStyle(
    // H2
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: _letterSpacing2,
    fontFamily: 'KBO',
  ),
  displaySmall: TextStyle(
    // H3
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: _letterSpacing2,
    fontFamily: 'KBO',
  ),
  titleLarge: TextStyle(
    // Subtitle1
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: _letterSpacing2,
    fontFamily: 'KBO',
  ),
  titleMedium: TextStyle(
    // Subtitle2
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: 'KBO',
  ),
  bodyLarge: TextStyle(
    // Body1
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: 'KBO',
  ),
  bodyMedium: TextStyle(
    // Body2
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: 'KBO',
  ),
  bodySmall: TextStyle(
    // Body3
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: 'KBO',
  ),
  labelSmall: TextStyle(
    // Caption
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: _letterSpacing3,
    fontFamily: 'KBO',
  ),
);


/*
  사용 예시

  import 'theme/app_theme.dart';

  Text('승리요정과 함께하는 KBO 직관 라이프!',
  style: Theme.of(context).textTheme.displayLarge,)
 */