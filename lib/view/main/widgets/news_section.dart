import 'package:flutter/material.dart';
import 'news_item.dart';

class NewsSection extends StatelessWidget {
  final List<Map<String, dynamic>> newsItems;
  final Function(String?) onNewsUrlTap;

  const NewsSection({
    Key? key,
    required this.newsItems,
    required this.onNewsUrlTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 소식은',
            style: TextStyle(
              color: Color(0xFF09004C),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'KBO',
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 12),
          _buildNewsList(),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
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

  Widget _buildNoNews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.article, size: 60, color: Color(0xFF656A77)),
          SizedBox(height: 16),
          Text(
            '최근 소식이 없습니다',
            style: TextStyle(
              color: Color(0xFF656A77),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
