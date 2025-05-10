import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final newsList = [
      {
        'image': 'assets/images/news1.png',
        'title': "'전 NC' 하트, 5시즌 만에 빅리그 ...",
        'content':
            "샌디에이고 유니폼 입고 치른 첫 경기서 5이닝 2실점 2024년 한국프로야구 KBO리그 투수 부문 골든글러브 수상자인 카일 하트(32·샌디에이고...",
      },
      {
        'image': 'assets/images/news2.png',
        'title': '"2030세대가 푹 빠졌다"…티빙, ‘KBO 리그’ 개막에 야구팬 몰려',
        'content':
            '정규 시즌이 시작되기도 전에 팬들의 관심은 이미 달아올랐다. 올해 KBO 리그 시범경기 시청 UV는 전년 대비 15% 증가,',
      },
      {
        'image': 'assets/images/news3.png',
        'title': "‘창원의 비극’ 슬픔 함께한 KBO리...",
        'content':
            "2024 한국시리즈 리턴매치다. 지난해에는 KIA가 12승4패로 압도했다. KIA는 이 분위기를 잇고 싶다. 삼성은 반격을 원한다.",
      },
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 소식은',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 16),
          ...newsList.map(
            (news) => _NewsCard(
              image: news['image']!,
              title: news['title']!,
              content: news['content']!,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String image;
  final String title;
  final String content;
  final TextTheme textTheme;
  const _NewsCard({
    required this.image,
    required this.title,
    required this.content,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 실제 적용시: Image.asset(image, width: 60, height: 60, fit: BoxFit.cover),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.gray20,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray60,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
