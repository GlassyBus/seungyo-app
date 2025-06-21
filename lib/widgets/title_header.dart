import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle을 위한 임포트

/// 앱 전체에서 일관된 앱바를 제공하는 컴포넌트
///
/// [title]은 중앙에 표시될 제목입니다.
/// [onBackPressed]가 제공되면 뒤로가기 버튼이 표시됩니다.
/// [actions]를 통해 오른쪽에 액션 버튼들을 추가할 수 있습니다.
/// [bottom]으로 탭바 등을 추가할 수 있습니다.
/// [backgroundColor], [elevation] 등으로 앱바의 스타일을 커스터마이징할 수 있습니다.
///
/// 기본 스타일은 앱의 appBarTheme에서 상속받습니다.
class TitleHeader extends StatelessWidget implements PreferredSizeWidget {
  /// 앱바 제목
  final String title;

  /// 뒤로가기 버튼 클릭 시 콜백
  final VoidCallback? onBackPressed;

  /// 오른쪽 액션 버튼 목록
  final List<Widget>? actions;

  /// 앱바 하단 위젯 (탭바 등)
  final PreferredSizeWidget? bottom;

  /// 앱바 배경색
  final Color? backgroundColor;

  /// 앱바 그림자 정도
  final double? elevation;

  /// 제목의 좌우 간격
  final double? titleSpacing;

  /// 자동 리딩 버튼 표시 여부
  final bool automaticallyImplyLeading;

  /// 제목 중앙 정렬 여부
  final bool? centerTitle;

  /// 제목 텍스트 스타일
  final TextStyle? titleTextStyle;

  /// 뒤로가기 버튼 아이콘
  final IconData backIcon;

  /// 뒤로가기 버튼 툴팁
  final String backButtonTooltip;

  /// 기본값 설정
  static const IconData _defaultBackIcon = Icons.arrow_back_ios;

  const TitleHeader({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.elevation,
    this.titleSpacing,
    this.automaticallyImplyLeading = true,
    this.centerTitle,
    this.titleTextStyle,
    this.backIcon = _defaultBackIcon,
    this.backButtonTooltip = '뒤로 가기',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      scrolledUnderElevation: elevation,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      centerTitle: centerTitle ?? appBarTheme.centerTitle ?? true,
      titleSpacing: titleSpacing ?? NavigationToolbar.kMiddleSpacing,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Semantics(
        header: true,
        namesRoute: true,
        label: '$title 화면',
        excludeSemantics: true,
        child: Text(
          title,
          style:
              titleTextStyle ??
              appBarTheme.titleTextStyle ??
              theme.textTheme.titleLarge,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: _buildLeadingWidget(theme, appBarTheme),
      actions: actions,
      bottom: bottom,
      systemOverlayStyle:
          theme.brightness == Brightness.light
              ? SystemUiOverlayStyle.dark
              : SystemUiOverlayStyle.light,
    );
  }

  /// 뒤로가기 버튼 위젯 생성
  Widget? _buildLeadingWidget(ThemeData theme, AppBarTheme appBarTheme) {
    if (onBackPressed == null) {
      return null;
    }

    return Semantics(
      button: true,
      label: backButtonTooltip,
      child: IconButton(
        icon: Icon(
          backIcon,
          color: appBarTheme.iconTheme?.color,
          size: appBarTheme.iconTheme?.size ?? 24,
        ),
        onPressed: onBackPressed,
        padding: EdgeInsets.zero,
        tooltip: backButtonTooltip,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
