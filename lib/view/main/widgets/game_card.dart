import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/game_schedule.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class GameCard extends StatelessWidget {
  final GameSchedule game;
  final VoidCallback? onEditTap;

  const GameCard({Key? key, required this.game, this.onEditTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${game.dateTime.hour.toString().padLeft(2, '0')}:${game.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${game.stadium}, $timeString',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTeamInfo(game.homeTeam),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'VS',
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildTeamInfo(game.awayTeam),
                  ],
                ),
              ],
            ),
          ),
          if (onEditTap != null)
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/icons/edit-20px.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String teamName) {
    // GameSchedule에서 해당 팀의 로고 경로 가져오기
    String? logoPath;
    if (teamName == game.homeTeam) {
      logoPath = game.homeTeamLogo;
    } else if (teamName == game.awayTeam) {
      logoPath = game.awayTeamLogo;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTeamLogo(teamName, logoPath),
        const SizedBox(width: 6),
        Text(
          teamName,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamLogo(String teamName, String? logoPath) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child:
          logoPath != null && logoPath.isNotEmpty
              ? ClipOval(
                child: Image.asset(
                  logoPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print(
                      'GameCard: Failed to load team logo: $logoPath for $teamName',
                    );
                    // 로고 로드 실패 시 기본 색상 원 표시
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getTeamColor(teamName),
                      ),
                      child: Center(
                        child: Text(
                          teamName.substring(0, 1),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
              : Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getTeamColor(teamName),
                ),
                child: Center(
                  child: Text(
                    teamName.substring(0, 1),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
    );
  }

  Color _getTeamColor(String teamName) {
    final teamColors = {
      'SSG': const Color(0xFFCF0022),
      '키움': const Color(0xFF570514),
      'LG': const Color(0xFFC30452),
      'KIA': const Color(0xFFEA0029),
      '한화': const Color(0xFFFF6600),
      '삼성': const Color(0xFF074CA1),
      '두산': const Color(0xFF131230),
      'KT': const Color(0xFF000000),
      'NC': const Color(0xFF315288),
      '롯데': const Color(0xFF041E42),
    };

    return teamColors[teamName] ?? AppColors.textSecondary;
  }
}
