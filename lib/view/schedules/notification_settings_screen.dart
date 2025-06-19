import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/notification_settings_provider.dart';

/// 알림 설정 화면
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationSettingsProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<NotificationSettingsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SafeArea(
              child: Column(
                children: [
                  // 헤더
                  _buildHeader(context),

                  // 알림 설정 리스트
                  Expanded(child: _buildNotificationList(provider)),

                  // 하단 완료 버튼
                  _buildBottomButton(context, provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 뒤로가기 버튼
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.black,
                size: 20,
              ),
            ),
          ),

          // 제목
          Expanded(
            child: Text(
              '알림 설정',
              style: AppTextStyles.subtitle1.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
          ),

          // 오른쪽 공간 (대칭을 위한 빈 공간)
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  /// 알림 설정 리스트
  Widget _buildNotificationList(NotificationSettingsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 25),

          // 경기 시작 알림
          _buildNotificationItem(
            title: '경기 시작 알림 (10분 전)',
            isEnabled: provider.gameStartNotification,
            onChanged: provider.setGameStartNotification,
          ),

          const SizedBox(height: 20),

          // 경기 끝 알림
          _buildNotificationItem(
            title: '경기 끝 알림 (3시간 후)',
            isEnabled: provider.gameEndNotification,
            onChanged: provider.setGameEndNotification,
          ),
        ],
      ),
    );
  }

  /// 알림 설정 항목 (피그마 디자인 정확히 따름)
  Widget _buildNotificationItem({
    required String title,
    required bool isEnabled,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 제목
        Text(
          title,
          style: AppTextStyles.subtitle1.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),

        // 커스텀 토글 스위치
        _buildCustomToggle(isEnabled, onChanged),
      ],
    );
  }

  /// 커스텀 토글 스위치 (피그마 디자인 정확히 구현)
  Widget _buildCustomToggle(bool isEnabled, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isEnabled),
      child: Container(
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.navy : AppColors.gray30,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: isEnabled ? 26 : 4,
              top: 4,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하단 완료 버튼 (피그마 디자인 정확히 따름)
  Widget _buildBottomButton(
    BuildContext context,
    NotificationSettingsProvider provider,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _onComplete(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '설정 완료',
              style: AppTextStyles.button1.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 완료 버튼 처리
  Future<void> _onComplete(
    BuildContext context,
    NotificationSettingsProvider provider,
  ) async {
    try {
      await provider.saveSettings();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('알림 설정이 저장되었습니다'),
          backgroundColor: AppColors.navy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('설정 저장에 실패했습니다: $error'),
          backgroundColor: AppColors.negative,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
