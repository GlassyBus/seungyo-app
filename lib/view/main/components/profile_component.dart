import 'package:flutter/material.dart';
import 'package:seungyo/models/user_profile.dart';
import 'package:seungyo/models/team.dart' as app_models;

class ProfileComponent extends StatelessWidget {
  /// 사용자 프로필 정보
  final UserProfile? userProfile;

  /// 선호하는 팀 정보
  final app_models.Team? favoriteTeam;

  /// 사용자 레벨
  final int level;

  /// 프리미엄 사용자 여부
  final bool isPremium;

  /// 더보기 버튼 콜백
  final VoidCallback? onMoreTap;

  /// 생성자
  const ProfileComponent({
    super.key,
    this.userProfile,
    this.favoriteTeam,
    this.level = 1,
    this.isPremium = false,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    // 사용자 닉네임 (기본값 제공)
    final userName = userProfile?.nickname ?? '승요 팬';

    // 팀 이름 (기본값 제공)
    final teamName = favoriteTeam?.name ?? 'LG 트윈스';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // 팀 로고 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6EAF2), width: 0.8),
              color: Colors.white,
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTeamLogo(),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '안녕하세요!',
                  style: TextStyle(
                    color: Color(0xFF7E8695),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'KBO',
                    letterSpacing: -0.03,
                  ),
                ),
                const SizedBox(height: 3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$teamName의 승요',
                      style: const TextStyle(
                        color: Color(0xFF09004C),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'KBO',
                        letterSpacing: -0.03,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            userName,
                            style: const TextStyle(
                              color: Color(0xFF09004C),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KBO',
                              letterSpacing: -0.02,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text(
                          '님',
                          style: TextStyle(
                            color: Color(0xFF7E8695),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'KBO',
                            letterSpacing: -0.02,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 더보기 아이콘
          GestureDetector(
            onTap: onMoreTap,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: const Icon(
                Icons.more_horiz,
                color: Color(0xFF9DA5B3),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 팀 로고 빌드
  Widget _buildTeamLogo() {
    if (favoriteTeam?.logo != null && favoriteTeam!.logo!.isNotEmpty) {
      if (favoriteTeam!.logo!.startsWith('assets/')) {
        // Assets 이미지
        return Image.asset(
          favoriteTeam!.logo!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackLogo();
          },
        );
      } else {
        // 이모지나 다른 텍스트
        return Center(
          child: Text(
            favoriteTeam!.logo!,
            style: const TextStyle(fontSize: 32),
          ),
        );
      }
    } else {
      return _buildFallbackLogo();
    }
  }

  /// 대체 로고 (팀명 첫 글자 또는 기본 아이콘)
  Widget _buildFallbackLogo() {
    if (favoriteTeam?.shortName != null && favoriteTeam!.shortName.isNotEmpty) {
      return Center(
        child: Text(
          favoriteTeam!.shortName.substring(0, 1),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF09004C),
          ),
        ),
      );
    } else {
      return const Center(
        child: Icon(Icons.sports_baseball, size: 32, color: Color(0xFF09004C)),
      );
    }
  }
}
