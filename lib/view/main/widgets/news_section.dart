import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'news_item.dart';

class NewsSection extends StatelessWidget {
  final List<Map<String, dynamic>> newsItems;
  final Function(String?) onNewsUrlTap;
  final bool isLoading; // 로딩 상태 추가

  const NewsSection({
    super.key,
    required this.newsItems,
    required this.onNewsUrlTap,
    this.isLoading = false, // 기본값 false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '최근 소식은',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildNewsList(),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    // 🔄 로딩 중일 때
    if (isLoading) {
      return _buildLoadingWidget();
    }

    if (newsItems.isEmpty) {
      return _buildNoNews();
    }

    return Column(
      children:
          newsItems
              .map(
                (news) => NewsItem(
                  newsData: news,
                  onTap: () => onNewsUrlTap(news['url']),
                ),
              )
              .toList(),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF09004C),
              ),
            ),
            SizedBox(height: 12),
            Text(
              '최근 소식을 불러오는 중...',
              style: TextStyle(
                color: Color(0xFF7E8695),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoNews() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/silent-120px.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            '소식이 없어요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
