import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';

class NewsItem extends StatelessWidget {
  final Map<String, dynamic> newsData;
  final Function()? onTap;

  const NewsItem({Key? key, required this.newsData, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = newsData['imageUrl'] != null;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray20.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage) _buildNewsImage(),
            SizedBox(width: hasImage ? 16 : 0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewsTitle(),
                  const SizedBox(height: 8),
                  _buildNewsContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 100,
        height: 80,
        child: Image.network(
          newsData['imageUrl'] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.gray20,
              child: Icon(
                Icons.image_not_supported,
                color: AppColors.gray60,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsTitle() {
    return Text(
      newsData['title'] ?? '',
      style: TextStyle(
        color: AppColors.navy,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNewsContent() {
    return Text(
      newsData['content'] ?? '',
      style: TextStyle(color: AppColors.gray60, fontSize: 14),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
