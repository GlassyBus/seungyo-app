import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuickActionButtons extends StatelessWidget {
  final VoidCallback onAddRecord;
  final VoidCallback onViewRecords;
  final VoidCallback onViewSchedule;
  final VoidCallback onViewStats;

  const QuickActionButtons({
    super.key,
    required this.onAddRecord,
    required this.onViewRecords,
    required this.onViewSchedule,
    required this.onViewStats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_circle_outline,
            label: '기록 추가',
            onTap: onAddRecord,
            color: AppColors.mint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.list_alt,
            label: '기록 보기',
            onTap: onViewRecords,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.calendar_today,
            label: '일정',
            onTap: onViewSchedule,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.bar_chart,
            label: '통계',
            onTap: onViewStats,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
