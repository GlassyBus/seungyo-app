import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 앱 상단 헤더 컴포넌트
///
/// 앱의 제목과 우측 액션 아이콘을 표시합니다.
class HeaderComponent extends StatelessWidget {
  /// 사용자 닉네임
  final String? nickname;

  /// 제목
  final String title;

  /// 우측 아이콘 경로
  final String iconAsset;

  /// 생성자
  const HeaderComponent({
    super.key,
    this.nickname,
    this.title = '홈',
    this.iconAsset = 'assets/icons/bell-25px.svg',
  });

  @override
  Widget build(BuildContext context) {
    // 환영 메시지 생성
    final welcomeMsg =
        nickname != null && nickname!.isNotEmpty
            ? '$nickname님, 안녕하세요!'
            : '안녕하세요!';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                welcomeMsg,
                style: const TextStyle(
                  fontFamily: 'KBO Dia Gothic',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.36,
                  color: Color(0xFF09004C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '오늘도 즐거운 야구 생활 되세요!',
                style: const TextStyle(
                  fontFamily: 'KBO Dia Gothic',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.28,
                  color: Color(0xFF7E8695),
                ),
              ),
            ],
          ),
          _buildIcon(iconAsset),
        ],
      ),
    );
  }

  /// 아이콘을 빌드합니다. SVG 또는 일반 이미지를 지원합니다.
  Widget _buildIcon(String iconPath) {
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFF100F21), BlendMode.srcIn),
      );
    } else {
      return Image.asset(iconPath, width: 24, height: 24, fit: BoxFit.contain);
    }
  }
}
