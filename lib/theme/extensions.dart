import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';

/// ColorScheme에 비활성화 색상 관련 속성 추가
/// 기본 ColorScheme에 없는 비활성화 상태의 컬러를 사용할 수 있게 합니다.
extension CustomColorScheme on ColorScheme {
  /// 비활성화된 버튼 등의 배경색
  Color get primaryDisabled => AppColors.primaryDisabled;

  /// 비활성화된 요소의 텍스트/아이콘 색상
  Color get onPrimaryDisabled => AppColors.onPrimaryDisabled;
}
