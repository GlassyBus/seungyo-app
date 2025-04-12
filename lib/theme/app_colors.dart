import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 정의
/// 브랜드 색상, 피드백 색상, 컬러 스케일 및 테마 색상 스키마를 포함합니다.
class AppColors {
  // === Brand Colors ===
  static const Color navy = Color(0xFF09004C);
  static const Color mint = Color(0xFF57FFCF);
  static const Color black = Color(0xFF100F21);

  // === Disabled Colors ===
  static Color primaryDisabled = navy5; // 비활성화된 primary 색상
  static Color onPrimaryDisabled = navy30; // 비활성화된 primary 위 텍스트 색상

  // === Feedback Colors ===
  static const Color negative = Color(0xFFEB4144);
  static const Color positive = Color(0xFF1FC988);
  static const Color warning = Color(0xFFFFC654);
  static const Color active = Color(0xFF0975F4);

  static const Color negativeBG = Color(0xFFFFE5E5);
  static const Color positiveBG = Color(0xFFC9F8ED);
  static const Color warningBG = Color(0xFFFFF2D6);
  static const Color activeBG = Color(0xFFD6E8FF);

  // === Navy Scale ===
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

  // === Gray Scale ===
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

  // === ColorScheme Light ===
  static final ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // 기본 색상
    primary: navy, // 주요 버튼, 강조 요소 등
    onPrimary: Colors.white, // 주요 요소 위 텍스트/아이콘
    primaryContainer: navy.withAlpha(204), // 주요 요소 컨테이너
    onPrimaryContainer: navy, // 주요 컨테이너 위 콘텐츠
    // 세컨더리 색상
    secondary: mint, // 부차적 요소, 보조 버튼 등
    onSecondary: navy, // 보조 요소 위 텍스트/아이콘
    secondaryContainer: mint.withAlpha(26), // 보조 컨테이너
    onSecondaryContainer: mint, // 보조 컨테이너 위 콘텐츠
    // 기본 배경 및 콘텐츠 색상
    surface: Colors.white, // 카드, 시트 등의 표면
    onSurface: black, // 표면 위 텍스트/아이콘
    surfaceContainer: gray5, // 컨테이너 배경
    // 이외 색상
    error: negative, // 오류, 경고 표시
    onError: Colors.white, // 오류 표시 위 텍스트/아이콘
    errorContainer: negative.withAlpha(51), // 오류 컨테이너
    onErrorContainer: negative, // 오류 컨테이너 위 콘텐츠
    // 대비, 윤곽 색상
    outline: gray30, // 테두리, 구분선 등
    outlineVariant: gray20, // 약한 테두리, 구분선
    // 투명도/그림자 조절
    surfaceTint: navy.withAlpha(13), // 표면 틴트 컬러
    scrim: black.withAlpha(77), // 모달 배경 등의 반투명 레이어
    // 추가 표면 변형 (Material Design 3)
    surfaceBright: Colors.white, // 밝은 표면
    surfaceContainerHighest: gray10, // 가장 높은 표면 컨테이너
    surfaceContainerHigh: gray5, // 높은 표면 컨테이너
    surfaceContainerLow: gray5.withAlpha(128), // 낮은 표면 컨테이너
    surfaceContainerLowest: Colors.white, // 가장 낮은 표면 컨테이너
    surfaceDim: gray10, // 어두운 표면
  );

  // === ColorScheme Dark (필요한 경우) ===
  static final ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // 기본 색상
    primary: mint,
    onPrimary: navy,
    primaryContainer: navy.withAlpha(204),
    onPrimaryContainer: mint,

    // 세컨더리 색상
    secondary: navy30,
    onSecondary: Colors.white,
    secondaryContainer: navy.withAlpha(77),
    onSecondaryContainer: Colors.white,

    // 기본 배경 및 콘텐츠 색상
    surface: gray100,
    onSurface: Colors.white,
    surfaceContainer: black,

    // 이외 색상
    error: negative,
    onError: Colors.white,
    errorContainer: negative.withAlpha(51),
    onErrorContainer: Colors.white,

    // 대비, 윤곽 색상
    outline: gray70,
    outlineVariant: gray50,

    // 투명도/그림자 조절
    surfaceTint: mint.withAlpha(26),
    scrim: Colors.black.withAlpha(77),

    surfaceBright: gray90,
    surfaceContainerHighest: Colors.black,
    surfaceContainerHigh: gray100,
    surfaceContainerLow: gray100.withAlpha(204),
    surfaceContainerLowest: gray90,
    surfaceDim: Colors.black,
  );
}

/* 
  ColorScheme 사용법:
  
  1. ThemeData에서 설정:
  ThemeData theme = ThemeData(
    colorScheme: AppColors.lightColorScheme,
    // 다른 테마 요소 설정
  );
  
  2. 컴포넌트에서 사용:
  Container(
    color: Theme.of(context).colorScheme.primary,
    child: Text(
      '이것은 예시입니다',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    ),
  );
  
  3. 버튼에서 사용:
  ElevatedButton(
    onPressed: () {},
    child: Text('버튼'),
  );
*/
