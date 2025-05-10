import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';

class MatchSection extends StatelessWidget {
  const MatchSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final matches = [
      {
        'date': '2025. 04. 08(화)',
        'place': '고척',
        'time': '14:00',
        'home': 'SSG',
        'homeLogo': 'assets/emblems/landers.png',
        'away': '키움',
        'awayLogo': 'assets/emblems/heroes.png',
      },
      {
        'date': '2025. 04. 08(화)',
        'place': '잠실',
        'time': '17:00',
        'home': 'LG',
        'homeLogo': 'assets/emblems/twins.png',
        'away': 'KIA',
        'awayLogo': 'assets/emblems/tigers.png',
      },
      {
        'date': '2025. 04. 08(화)',
        'place': '잠실',
        'time': '18:30',
        'home': '한화',
        'homeLogo': 'assets/emblems/eagles.png',
        'away': '삼성',
        'awayLogo': 'assets/emblems/lions.png',
      },
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 경기는',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            matches[0]['date']!,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          ...matches.map(
            (match) => _MatchCard(match: match, textTheme: textTheme),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Map<String, String> match;
  final TextTheme textTheme;
  const _MatchCard({required this.match, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${match['place']}, ${match['time']}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // 실제 적용시: Image.asset(match['homeLogo']!, width: 28, height: 28),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.gray20,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match['home']!,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VS',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray60,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match['away']!,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 실제 적용시: Image.asset(match['awayLogo']!, width: 28, height: 28),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.gray20,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.edit, color: AppColors.gray60, size: 22),
        ],
      ),
    );
  }
}
