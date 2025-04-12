import 'package:flutter/material.dart';
import 'package:seungyo/theme/extensions.dart';

/// 앱에서 사용하는 기본 버튼 컴포넌트
///
/// 메인 액션이나 사용자가 취할 주요 동작에 사용합니다.
/// [onTap]은 버튼 클릭 시 실행될 콜백입니다.
/// [text]는 버튼에 표시될 텍스트입니다.
/// [isEnabled]는 버튼의 활성화 상태를 결정합니다. 기본값은 true입니다.
class PrimaryButton extends StatelessWidget {
  /// 버튼 클릭 시 실행될 콜백
  final VoidCallback? onTap;

  /// 버튼에 표시될 텍스트
  final String text;

  /// 버튼의 활성화 상태
  final bool isEnabled;

  /// 버튼 높이 (기본값: 48)
  final double? height;

  /// 아이콘 (선택 사항)
  final IconData? icon;

  /// 버튼 내부 패딩
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isEnabled = true,
    this.height,
    this.icon,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  });

  /// '다음' 텍스트로 다음 단계 버튼 생성을 위한 팩토리 생성자
  factory PrimaryButton.next({
    Key? key,
    required VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return PrimaryButton(
      key: key,
      onTap: onTap,
      text: '다음',
      isEnabled: isEnabled,
    );
  }

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
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
