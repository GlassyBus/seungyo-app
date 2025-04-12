import 'package:flutter/material.dart';
import 'package:seungyo/theme/extensions.dart';

/// 앱 전체에서 일관된 다음 단계로 진행하는 버튼을 제공하는 컴포넌트
///
/// [onTap]은 버튼 클릭 시 실행될 콜백입니다.
/// [text]는 버튼에 표시될 텍스트입니다. 기본값은 '다음'입니다.
/// [isEnabled]는 버튼의 활성화 상태를 결정합니다. 기본값은 true입니다.
class NextButton extends StatelessWidget {
  /// 버튼 클릭 시 실행될 콜백
  final VoidCallback? onTap;

  /// 버튼에 표시될 텍스트
  final String text;

  /// 버튼의 활성화 상태
  final bool isEnabled;

  const NextButton({
    super.key,
    required this.onTap,
    this.text = '다음',
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // 버튼 스타일 정의
    final backgroundColor =
        isEnabled ? colorScheme.primary : colorScheme.primaryDisabled;

    final textColor =
        isEnabled ? colorScheme.onPrimary : colorScheme.onPrimaryDisabled;

    // 버튼의 레이아웃 및 동작 정의
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
