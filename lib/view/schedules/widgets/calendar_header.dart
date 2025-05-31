import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seungyo/theme/app_colors.dart';

/// 캘린더 헤더 위젯
class CalendarHeader extends StatefulWidget {
  final DateTime currentMonth;
  final Function(int) onMonthChanged;
  final VoidCallback? onTodayPressed;

  const CalendarHeader({
    Key? key,
    required this.currentMonth,
    required this.onMonthChanged,
    this.onTodayPressed,
  }) : super(key: key);

  @override
  State<CalendarHeader> createState() => _CalendarHeaderState();
}

class _CalendarHeaderState extends State<CalendarHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  /// 애니메이션 초기화
  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CalendarHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final koreanFormat = DateFormat('yyyy년 M월', 'ko_KR');
    final now = DateTime.now();
    final isCurrentMonth =
        widget.currentMonth.year == now.year &&
        widget.currentMonth.month == now.month;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildHeaderContent(textTheme, koreanFormat, isCurrentMonth),
          ),
        );
      },
    );
  }

  /// 헤더 내용 위젯 생성
  Widget _buildHeaderContent(
    TextTheme textTheme,
    DateFormat koreanFormat,
    bool isCurrentMonth,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthTitle(textTheme, koreanFormat),
                if (!isCurrentMonth) const SizedBox(height: 4),
                if (!isCurrentMonth) _buildTodayButton(textTheme),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// 월 제목 위젯 생성
  Widget _buildMonthTitle(TextTheme textTheme, DateFormat koreanFormat) {
    return GestureDetector(
      onTap: widget.onTodayPressed,
      child: Text(
        koreanFormat.format(widget.currentMonth),
        style: textTheme.displaySmall?.copyWith(
          color: AppColors.navy,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 오늘 버튼 위젯 생성
  Widget _buildTodayButton(TextTheme textTheme) {
    return GestureDetector(
      onTap: widget.onTodayPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.mint.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '오늘로 이동',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 네비게이션 버튼 위젯 생성
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        _buildNavigationButton(
          Icons.chevron_left,
          () => widget.onMonthChanged(-1),
          'Previous month',
        ),
        const SizedBox(width: 8),
        _buildNavigationButton(
          Icons.chevron_right,
          () => widget.onMonthChanged(1),
          'Next month',
        ),
      ],
    );
  }

  /// 네비게이션 버튼 위젯 생성
  Widget _buildNavigationButton(
    IconData icon,
    VoidCallback onPressed,
    String tooltip,
  ) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navy5,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              child: Icon(icon, color: AppColors.navy, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
