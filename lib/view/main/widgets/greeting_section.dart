import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 실제 적용시: Image.asset('assets/emblems/bears.png', width: 72, height: 72, fit: BoxFit.cover),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.gray10,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray30, width: 1),
            ),
            child: Center(
              child: Text('Bears', style: TextStyle(color: AppColors.gray40)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '안녕하세요!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.gray60,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'KBO',
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '두산 베어스의 승요',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.navy,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'KBO',
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '두산승리요정',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'KBO',
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: '님',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.gray60,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'KBO',
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.more_horiz, color: AppColors.gray40, size: 28),
        ],
      ),
    );
  }
}
