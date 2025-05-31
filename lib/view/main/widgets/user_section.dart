import 'package:flutter/material.dart';
import '../../../models/team.dart';
import '../../../models/user_profile.dart';

class UserSection extends StatelessWidget {
  final UserProfile? userProfile;
  final Team? favoriteTeam;
  final VoidCallback? onMoreTap;

  const UserSection({
    Key? key,
    this.userProfile,
    this.favoriteTeam,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teamName = favoriteTeam?.name ?? '두산 베어스';
    final nickname = userProfile?.nickname ?? '두산승리요정';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6EAF2), width: 0.8),
              color: Colors.white,
            ),
            child: ClipOval(
              child: Container(
                margin: const EdgeInsets.all(9.6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/profile_placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
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
                      '${teamName}의 승요',
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
                        Text(
                          nickname,
                          style: const TextStyle(
                            color: Color(0xFF09004C),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'KBO',
                            letterSpacing: -0.02,
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
}
