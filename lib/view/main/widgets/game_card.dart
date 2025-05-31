import 'package:flutter/material.dart';
import '../../../models/game_schedule.dart';

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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${game.stadium}, $timeString',
                style: const TextStyle(
                  color: Color(0xFF09004C),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'KBO',
                  letterSpacing: -0.03,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildTeamInfo(game.homeTeam),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: Color(0xFF9DA5B3),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'KBO',
                        letterSpacing: -0.03,
                      ),
                    ),
                  ),
                  _buildTeamInfo(game.awayTeam),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: const Icon(Icons.edit, color: Color(0xFF100F21), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(String teamName) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: _getTeamLogo(teamName),
        ),
        const SizedBox(width: 4),
        Text(
          teamName,
          style: const TextStyle(
            color: Color(0xFF100F21),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'KBO',
            letterSpacing: -0.03,
          ),
        ),
      ],
    );
  }

  Widget _getTeamLogo(String teamName) {
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

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: teamColors[teamName] ?? const Color(0xFF9DA5B3),
      ),
    );
  }
}
