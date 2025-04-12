import 'package:flutter/material.dart';
import 'app_text_styles.dart';

TextTheme appTextTheme = const TextTheme(
  displayLarge: AppTextStyles.h1,
  displayMedium: AppTextStyles.h2,
  displaySmall: AppTextStyles.h3,
  titleLarge: AppTextStyles.subtitle1,
  titleMedium: AppTextStyles.subtitle2,
  bodyLarge: AppTextStyles.body1,
  bodyMedium: AppTextStyles.body2,
  bodySmall: AppTextStyles.body3,
  labelSmall: AppTextStyles.caption,
);


/*
  사용 예시
  Text(
    '승요',
    style: Theme.of(context).textTheme.displayLarge, // H1
  );
 */