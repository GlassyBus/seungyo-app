import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 12,
      color: AppColors.gray10,
      margin: const EdgeInsets.symmetric(vertical: 24),
    );
  }
}
