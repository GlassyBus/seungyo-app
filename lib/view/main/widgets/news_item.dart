import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class NewsItem extends StatelessWidget {
  final Map<String, dynamic> newsData;
  final Function()? onTap;

  const NewsItem({super.key, required this.newsData, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray5,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildNewsImage(),
            const SizedBox(width: 12),
            Expanded(child: _buildNewsContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.gray20,
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          newsData['imageUrl'] != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  newsData['imageUrl']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                ),
              )
              : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray20,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.gray60,
        size: 24,
      ),
    );
  }

  Widget _buildNewsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          newsData['title'] ?? '제목 없음',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          newsData['content'] ?? newsData['description'] ?? '내용 없음',
          style: AppTextStyles.body3.copyWith(
            color: AppColors.gray80,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
