import 'package:flutter/material.dart';
import '../models/game.dart';

/// 오늘의 경기 컴포넌트
///
/// 오늘 예정된 경기 목록을 표시합니다.
class GamesTodayComponent extends StatelessWidget {
  /// 표시할 경기 목록
  final List<Game>? games;

  /// 섹션 제목
  final String title;

  /// 경기 날짜
  final String date;

  /// 취소 여부
  final bool isCanceled;

  /// 경기 카드 클릭 콜백
  final Function(Game)? onGameTapped;

  /// 생성자
  const GamesTodayComponent({
    Key? key,
    this.games,
    this.title = '오늘의 경기는',
    this.date = '2025. 04. 08(화)',
    this.isCanceled = false,
    this.onGameTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 경기 목록이 null이거나 비어있으면 기본 경기 목록 생성
    final gamesList = games ?? _getDefaultGames();
    final hasGames = gamesList.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.36,
              color: Color(0xFF09004C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF100F21),
              letterSpacing: -0.48,
            ),
          ),
          const SizedBox(height: 12),
          if (isCanceled)
            _buildCanceledView()
          else if (!hasGames)
            _buildNoGameView()
          else
            Column(
              children: gamesList.map((game) => _buildGameCard(game)).toList(),
            ),
        ],
      ),
    );
  }

  /// 기본 경기 목록 생성
  List<Game> _getDefaultGames() {
    return [
      Game(
        location: '고척, 14:00',
        team1: 'SSG',
        team1Image: 'assets/emblems/ssg.png',
        team2: '키움',
        team2Image: 'assets/emblems/kiwoom.png',
        editIcon: 'assets/icons/edit-20px.svg',
      ),
      Game(
        location: '잠실, 17:00',
        team1: 'LG',
        team1Image: 'assets/emblems/lg.png',
        team2: 'KIA',
        team2Image: 'assets/emblems/kia.png',
        editIcon: 'assets/icons/edit-20px.svg',
      ),
      Game(
        location: '잠실, 18:30',
        team1: '한화',
        team1Image: 'assets/emblems/hanwha.png',
        team2: '삼성',
        team2Image: 'assets/emblems/samsung.png',
        editIcon: 'assets/icons/edit-20px.svg',
      ),
    ];
  }

  /// 경기 취소 안내 위젯
  Widget _buildCanceledView() {
    return Container(
      width: double.infinity,
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/umbrella-120px.png',
            width: 70,
            height: 70,
          ),
          const SizedBox(height: 12),
          const Text(
            '우천으로 취소되었어요.',
            style: TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF09004C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '일주일에 하루뿐인 휴식이 아닌 날',
            style: TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 14,
              color: Color(0xFF7E8695),
            ),
          ),
        ],
      ),
    );
  }

  /// 경기가 없는 날 위젯
  Widget _buildNoGameView() {
    return Container(
      width: double.infinity,
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/break-time-120px.png',
            width: 70,
            height: 70,
          ),
          const SizedBox(height: 12),
          const Text(
            '경기가 없는 날이에요.',
            style: TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF09004C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '일주일에 하루뿐인 휴식이 아닌 날',
            style: TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 14,
              color: Color(0xFF7E8695),
            ),
          ),
        ],
      ),
    );
  }

  /// 경기 카드 위젯을 빌드합니다.
  Widget _buildGameCard(Game game) {
    return GestureDetector(
      onTap: () {
        if (onGameTapped != null) {
          onGameTapped!(game);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.location,
                    style: const TextStyle(
                      fontFamily: 'KBO Dia Gothic',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF09004C),
                      letterSpacing: -0.42,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTeam(game.team1, game.team1Image),
                      const SizedBox(width: 6),
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontFamily: 'KBO Dia Gothic',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9DA5B3),
                          letterSpacing: -0.42,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildTeam(game.team2, game.team2Image),
                    ],
                  ),
                ],
              ),
            ),
            _buildEditIcon(game.editIcon),
          ],
        ),
      ),
    );
  }

  /// 편집 아이콘을 빌드합니다. SVG 또는 일반 이미지를 지원합니다.
  Widget _buildEditIcon(String iconPath) {
    if (iconPath.endsWith('.svg')) {
      // SVG 이미지는 flutter_svg 패키지 사용
      // 여기서는 간단하게 일반 이미지로 처리
      return Image.asset(
        iconPath.replaceAll('.svg', '.png'),
        width: 20,
        height: 20,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 20,
            height: 20,
            color: const Color(0xFF9DA5B3),
          );
        },
      );
    } else {
      return Image.asset(iconPath, width: 20, height: 20);
    }
  }

  /// 팀 정보(이름과 로고)를 표시하는 위젯을 빌드합니다.
  Widget _buildTeam(String name, String imageUrl) {
    return Row(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'KBO Dia Gothic',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF100F21),
            letterSpacing: -0.48,
          ),
        ),
        const SizedBox(width: 4),
        Image.asset(imageUrl, width: 25, height: 25),
      ],
    );
  }
}
