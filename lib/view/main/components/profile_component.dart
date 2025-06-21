import 'package:flutter/material.dart';
import 'package:seungyo/models/user_profile.dart';
import 'package:seungyo/models/team.dart' as app_models;

class ProfileComponent extends StatelessWidget {
  /// 사용자 프로필 정보
  final UserProfile? profile;

  /// 선호하는 팀 정보
  final app_models.Team? team;

  /// 더보기 버튼 콜백
  final VoidCallback? onTap;

  /// 생성자
  const ProfileComponent({super.key, this.profile, this.team, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 프로필 이미지 또는 기본 아바타
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12),

            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.nickname ?? '사용자',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (team != null)
                    Text(
                      '${team!.name} 팬',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),

            // 화살표 아이콘
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
