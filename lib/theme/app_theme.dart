import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_text_theme.dart';

/// 라이트 모드용 앱 테마를 생성합니다.
/// 메인 색상과 텍스트 스타일을 포함합니다.
ThemeData createLightTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightColorScheme,
    fontFamily: AppTextStyles.fontFamily,
    textTheme: appTextTheme,
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.lightColorScheme.surface,
      foregroundColor: AppColors.lightColorScheme.onSurface,
      iconTheme: IconThemeData(
        color: AppColors.lightColorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.lightColorScheme.onSurface,
        size: 24,
      ),
      titleTextStyle: appTextTheme.titleLarge?.copyWith(
        color: AppColors.lightColorScheme.onSurface,
      ),
      centerTitle: true,
    ),
  );
}

/// 다크 모드용 앱 테마를 생성합니다.
/// 어두운 배경에 어울리는 색상 구성으로 설정되어 있습니다.
ThemeData createDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.darkColorScheme,
    fontFamily: AppTextStyles.fontFamily,
    textTheme: appTextTheme,
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.darkColorScheme.surface,
      foregroundColor: AppColors.darkColorScheme.onSurface,
      iconTheme: IconThemeData(
        color: AppColors.darkColorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.darkColorScheme.onSurface,
        size: 24,
      ),
      titleTextStyle: appTextTheme.titleLarge?.copyWith(
        color: AppColors.darkColorScheme.onSurface,
      ),
      centerTitle: true,
    ),
  );
}
