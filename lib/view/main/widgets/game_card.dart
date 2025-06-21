import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/game_record.dart';
import '../../../models/game_schedule.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class GameCard extends StatelessWidget {
  final GameSchedule game;
  final GameRecord? attendedRecord; // 직관 기록 추가
  final VoidCallback? onEditTap;

  const GameCard({
    super.key,
    required this.game,
    this.attendedRecord,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${game.dateTime.hour.toString().padLeft(2, '0')}:${game.dateTime.minute.toString().padLeft(2, '0')}';

    // 직관 기록이 있는 경우와 없는 경우 다르게 렌더링
    if (attendedRecord != null) {
      return _buildAttendedGameCard(timeString);
    } else {
      return _buildRegularGameCard(timeString);
    }
  }

  /// 직관 기록이 있는 경기 카드 (피그마 디자인)
  Widget _buildAttendedGameCard(String timeString) {
    final record = attendedRecord!;

    // 승부 결과 판단
    String resultText = '';

    if (record.canceled) {
      resultText = 'PPD';
    } else if (record.result == GameResult.win) {
      resultText = 'WIN';
    } else if (record.result == GameResult.lose) {
      resultText = 'LOSE';
    } else if (record.result == GameResult.draw) {
      resultText = 'DRAW';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 왼쪽: 결과 태그 + 경기 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 결과 태그
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    resultText,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // 경기장과 시간
                Text(
                  '${game.stadium}, $timeString',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),

                // 팀 정보와 스코어
                const SizedBox(height: 6),
                Row(
                  children: [
                    // 홈팀 (응원팀)
                    _buildTeamWithScore(
                      record.homeTeam.name,
                      record.homeTeam.logo,
                      record.homeScore.toString(),
                      isRight: false,
                    ),

                    // VS
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        'VS',
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.gray50,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // 어웨이팀 (상대팀)
                    _buildTeamWithScore(
                      record.awayTeam.name,
                      record.awayTeam.logo,
                      record.awayScore.toString(),
                      isRight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 오른쪽: "직관 기록 보기" 버튼
          if (onEditTap != null)
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '직관 기록 보기',
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.gray70,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: 3.14159, // 180도 회전 (왼쪽 화살표를 오른쪽으로)
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 15,
                        color: AppColors.gray70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 직관 기록이 없는 일반 경기 카드
  Widget _buildRegularGameCard(String timeString) {
    // 경기 취소 또는 연기 여부 확인
    final isCanceledOrPostponed =
        game.status == GameStatus.canceled ||
        game.status == GameStatus.postponed;

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
                // 경기 취소/연기 태그 추가
                if (isCanceledOrPostponed) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PPD',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
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
          if (onEditTap != null && !isCanceledOrPostponed) // 취소/연기된 경기는 편집 불가
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

  /// 팀 이름과 스코어를 함께 표시하는 위젯 (직관 기록용)
  Widget _buildTeamWithScore(
    String teamName,
    String? logoPath,
    String score, {
    required bool isRight,
  }) {
    final shortName = _getShortTeamName(teamName);

    if (isRight) {
      // 오른쪽 정렬 (점수 + 팀명 + 로고)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            score,
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            shortName,
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          _buildTeamLogo(shortName, logoPath),
        ],
      );
    } else {
      // 왼쪽 정렬 (로고 + 팀명 + 점수)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTeamLogo(shortName, logoPath),
          const SizedBox(width: 4),
          Text(
            shortName,
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            score,
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
  }

  /// 팀 이름에서 짧은 이름 추출
  String _getShortTeamName(String fullName) {
    // "SSG 랜더스" -> "SSG", "키움 히어로즈" -> "키움" 등
    final shortNames = {
      'SSG 랜더스': 'SSG',
      '키움 히어로즈': '키움',
      'LG 트윈스': 'LG',
      'KIA 타이거즈': 'KIA',
      '한화 이글스': '한화',
      '삼성 라이온즈': '삼성',
      '두산 베어스': '두산',
      'KT 위즈': 'KT',
      'NC 다이노스': 'NC',
      '롯데 자이언츠': '롯데',
    };

    return shortNames[fullName] ?? fullName.split(' ')[0];
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
                    if (kDebugMode) {
                      print(
                        'GameCard: Failed to load team logo: $logoPath for $teamName',
                      );
                    }
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
