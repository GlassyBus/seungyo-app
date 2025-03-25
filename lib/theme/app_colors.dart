import 'package:flutter/material.dart';

class AppColors {
  // === Brand ===
  static const Color navy = Color(0xFF09004C);
  static const Color mint = Color(0xFF57FFCF);
  static const Color black = Color(0xFF100F21);

  // === UI ===
  static const Color negative = Color(0xFFEB4144);
  static const Color positive = Color(0xFF1FC988);
  static const Color warning = Color(0xFFFFC654);
  static const Color active = Color(0xFF0975F4);

  static const Color negativeBG = Color(0xFFFFE5E5);
  static const Color positiveBG = Color(0xFFC9F8ED);
  static const Color warningBG = Color(0xFFFFF2D6);
  static const Color activeBG = Color(0xFFD6E8FF);

  // === Color System ===
  // Navy Scale
  static const Color navy5 = Color(0xFFF0F4FF);
  static const Color navy10 = Color(0xFFE1E7FF);
  static const Color navy20 = Color(0xFFCCD6FF);
  static const Color navy30 = Color(0xFFBBC5F8);
  static const Color navy40 = Color(0xFFA4ADDC);
  static const Color navy50 = Color(0xFF8895D9);
  static const Color navy60 = Color(0xFF6796C2);
  static const Color navy70 = Color(0xFF575FAE);
  static const Color navy80 = Color(0xFF3D4195);
  static const Color navy90 = Color(0xFF222268);
  static const Color navy100 = Color(0xFF09004C);

  // Mint Scale
  static const Color mint10 = Color(0xFFE6FFF8);
  static const Color mint20 = Color(0xFFD5FFFA);
  static const Color mint30 = Color(0xFFBDFFEA);
  static const Color mint40 = Color(0xFFCAEDCA);
  static const Color mint50 = Color(0xFF57FFCF);
  static const Color mint60 = Color(0xFF27F6C3);
  static const Color mint70 = Color(0xFF00E5BE);
  static const Color mint80 = Color(0xFF00D3B7);
  static const Color mint90 = Color(0xFF00C4B0);
  static const Color mint100 = Color(0xFF0090A1);

  // Gray Scale
  static const Color gray5 = Color(0xFFFAFAFA);
  static const Color gray10 = Color(0xFFF6F6F6);
  static const Color gray20 = Color(0xFFEAEAEA);
  static const Color gray30 = Color(0xFFD7D7D7);
  static const Color gray40 = Color(0xFFC2C2CA);
  static const Color gray50 = Color(0xFFB5BDC8);
  static const Color gray60 = Color(0xFFA9A9A9);
  static const Color gray70 = Color(0xFF9095A3);
  static const Color gray80 = Color(0xFF7B8695);
  static const Color gray90 = Color(0xFF4C4F5D);
  static const Color gray100 = Color(0xFF313345);
}


/*
  사용 예시
  ** color: AppColors.테마이름, **

  텍스트에 적용한 경우
  ** color: AppColors.navy100, **
  Text(
    '승요!',
    style: TextStyle(
      color: AppColors.navy100,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  );

  ** 배경 **
  Container(
    color: AppColors.activeBG,
    child: Text('활성화됨'),
  );
 */
