import 'package:flutter/material.dart';
import 'package:seungyo/theme/theme.dart';

class RecordActionModal extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RecordActionModal({super.key, this.onEdit, this.onDelete});

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => RecordActionModal(onEdit: onEdit, onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionItem(
                context: context,
                icon: Icons.edit_outlined,
                title: '기록 수정하기',
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              _buildDivider(),
              _buildActionItem(
                context: context,
                icon: Icons.delete_outline,
                title: '기록 삭제하기',
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
                isDestructive: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final color =
        isDestructive
            ? AppColors.negative
            : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(title, style: textTheme.bodyLarge?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.gray10,
    );
  }
}
