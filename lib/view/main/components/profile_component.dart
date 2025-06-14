import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 사용자 프로필 컴포넌트
///
/// 사용자 프로필 이미지와 인사말, 팀 정보, 사용자명을 표시합니다.
class ProfileComponent extends StatelessWidget {
  /// 인사말
  final String greeting;

  /// 팀 정보
  final String teamInfo;

  /// 사용자 이름
  final String userName;

  /// 프로필 이미지 경로
  final String profileImage;

  /// 더보기 아이콘 경로
  final String moreIcon;

  /// 사용자 닉네임
  final String? nickname;

  /// 선호하는 팀
  final String? favoriteTeam;

  /// 팀 로고 이미지 경로
  final String? teamLogoImage;

  /// 사용자 레벨
  final int level;

  /// 프리미엄 사용자 여부
  final bool isPremium;

  /// 생성자
  const ProfileComponent({
    Key? key,
    this.greeting = '안녕하세요!',
    this.teamInfo = '두산 베어스의 승요',
    this.userName = '두산승리요정',
    this.profileImage = 'assets/images/splash_symbol.png',
    this.moreIcon = 'assets/icons/more-25px.svg',
    this.nickname,
    this.favoriteTeam,
    this.teamLogoImage,
    this.level = 1,
    this.isPremium = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userName = nickname ?? '승요 팬';
    final team = favoriteTeam ?? 'LG 트윈스';
    final teamLogo = teamLogoImage ?? 'assets/emblems/lg.png';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFFF7F8FB), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildTeamLogoImage(teamLogo),
          const SizedBox(width: 16),
          Expanded(child: _buildUserInfo(userName, team)),
          _buildLevelBadge(),
        ],
      ),
    );
  }

  /// 팀 로고 이미지 위젯
  Widget _buildTeamLogoImage(String logoPath) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: AssetImage(logoPath), fit: BoxFit.contain),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
      ),
    );
  }

  /// 사용자 정보 위젯
  Widget _buildUserInfo(String name, String team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontFamily: 'KBO Dia Gothic',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.32,
                color: Color(0xFF100F21),
              ),
            ),
            if (isPremium)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    fontFamily: 'KBO Dia Gothic',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '응원팀: $team',
          style: const TextStyle(
            fontFamily: 'KBO Dia Gothic',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.28,
            color: Color(0xFF7E8695),
          ),
        ),
      ],
    );
  }

  /// 레벨 배지 위젯
  Widget _buildLevelBadge() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF09004C)),
      child: Center(
        child: Text(
          'Lv.$level',
          style: const TextStyle(
            fontFamily: 'KBO Dia Gothic',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 더보기 버튼을 빌드합니다.
  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: () {
        // 더보기 버튼 탭 이벤트 핸들러
      },
      child: _buildIcon(moreIcon),
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
