import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../models/game_record.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/date_utils.dart';

class EnhancedCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime currentMonth;
  final Map<DateTime, List<GameRecord>> scheduleMap;
  final Function(DateTime) onDateSelected;
  final Function(int) onMonthChanged;

  const EnhancedCalendar({
    Key? key,
    required this.selectedDate,
    required this.currentMonth,
    required this.scheduleMap,
    required this.onDateSelected,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  State<EnhancedCalendar> createState() => _EnhancedCalendarState();
}

class _EnhancedCalendarState extends State<EnhancedCalendar>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentPageIndex = 1000; // 중간값으로 시작하여 양방향 스크롤 가능
  DateTime? _longPressedDate;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  /// 컨트롤러 초기화
  void _initControllers() {
    _pageController = PageController(initialPage: _currentPageIndex);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  /// 애니메이션 초기화
  void _initAnimations() {
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  /// 컨트롤러 해제
  void _disposeControllers() {
    _pageController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
  }

  /// 페이지 인덱스에 해당하는 월 계산
  DateTime _getMonthForPage(int pageIndex) {
    final monthDiff = pageIndex - _currentPageIndex;
    return DateTime(
      widget.currentMonth.year,
      widget.currentMonth.month + monthDiff,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildWeekdayHeaders(), _buildCalendarPages()]);
  }

  /// 요일 헤더 위젯 생성
  Widget _buildWeekdayHeaders() {
    final textTheme = Theme.of(context).textTheme;
    final weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children:
            weekdayLabels.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;

              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: index == 0 ? Colors.red : AppColors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  /// 캘린더 페이지 위젯 생성
  Widget _buildCalendarPages() {
    return SizedBox(
      height: 300, // 고정 높이
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        itemBuilder: (context, pageIndex) {
          final month = _getMonthForPage(pageIndex);
          return _buildCalendarGrid(month);
        },
      ),
    );
  }

  /// 페이지 변경 핸들러
  void _handlePageChanged(int pageIndex) {
    final monthDiff = pageIndex - _currentPageIndex;
    widget.onMonthChanged(monthDiff);
    _currentPageIndex = pageIndex;
    _slideController.forward().then((_) {
      _slideController.reset();
    });
  }

  /// 캘린더 그리드 위젯 생성
  Widget _buildCalendarGrid(DateTime month) {
    final calendarDays = AppDateUtils.generateCalendarDays(month);

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            ),
            itemCount: calendarDays.length,
            itemBuilder: (context, index) {
              final day = calendarDays[index];
              return _buildCalendarDay(day, month);
            },
          ),
        );
      },
    );
  }

  /// 캘린더 날짜 셀 위젯 생성
  Widget _buildCalendarDay(DateTime day, DateTime month) {
    final isCurrentMonth = day.month == month.month;
    final isSelected = AppDateUtils.isSameDay(day, widget.selectedDate);
    final isToday = AppDateUtils.isSameDay(day, DateTime.now());
    final isLongPressed =
        _longPressedDate != null &&
        AppDateUtils.isSameDay(day, _longPressedDate!);

    // 해당 날짜의 직관 기록 가져오기
    final dateKey = DateTime(day.year, day.month, day.day);
    final dayRecords = widget.scheduleMap[dateKey] ?? [];

    // 경기 결과 분석
    final gameResults = _analyzeGameResults(dayRecords);

    return GestureDetector(
      onTap: isCurrentMonth ? () => _selectDate(day) : null,
      onLongPress: isCurrentMonth ? () => _longPressDate(day) : null,
      onLongPressEnd: (_) => _endLongPress(),
      child: AnimatedScale(
        scale: isLongPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _getDateBackgroundColor(gameResults, isSelected, isToday),
            borderRadius: BorderRadius.circular(8),
            border: _getDateBorder(isSelected, isToday),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.navy.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Stack(
            children: [
              // 메인 날짜 텍스트
              Center(
                child: Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _getDateTextColor(
                      gameResults,
                      isCurrentMonth,
                      isSelected,
                    ),
                    fontWeight:
                        isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),

              // 경기 수 표시
              if (dayRecords.isNotEmpty && isCurrentMonth)
                Positioned(
                  top: 2,
                  right: 2,
                  child: _buildGameCountBadge(dayRecords.length),
                ),

              // 특별한 경기 표시 (즐겨찾기 등)
              if (_hasSpecialGames(dayRecords) && isCurrentMonth)
                Positioned(
                  bottom: 2,
                  left: 2,
                  child: _buildSpecialGameIndicator(),
                ),

              // 오늘 날짜 표시
              if (isToday && !isSelected)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 날짜 배경색 계산
  Color _getDateBackgroundColor(
    Map<GameResult, int> gameResults,
    bool isSelected,
    bool isToday,
  ) {
    if (isSelected) {
      return AppColors.navy;
    }

    // 경기 결과에 따른 배경색 (우선순위: 승리 > 무승부 > 패배)
    if (gameResults[GameResult.win] != null &&
        gameResults[GameResult.win]! > 0) {
      return AppColors.mint.withOpacity(0.8);
    } else if (gameResults[GameResult.draw] != null &&
        gameResults[GameResult.draw]! > 0) {
      return AppColors.gray30.withOpacity(0.8);
    } else if (gameResults[GameResult.lose] != null &&
        gameResults[GameResult.lose]! > 0) {
      return AppColors.navy.withOpacity(0.8);
    }

    if (isToday) {
      return AppColors.mint.withOpacity(0.2);
    }

    return Colors.transparent;
  }

  /// 날짜 테두리 계산
  Border? _getDateBorder(bool isSelected, bool isToday) {
    if (isSelected) {
      return Border.all(color: AppColors.mint, width: 2);
    }
    if (isToday) {
      return Border.all(color: AppColors.mint, width: 1);
    }
    return null;
  }

  /// 날짜 텍스트 색상 계산
  Color _getDateTextColor(
    Map<GameResult, int> gameResults,
    bool isCurrentMonth,
    bool isSelected,
  ) {
    if (!isCurrentMonth) {
      return AppColors.gray30;
    }

    if (isSelected) {
      return Colors.white;
    }

    // 패배가 있는 경우 흰색 텍스트
    if (gameResults[GameResult.lose] != null &&
        gameResults[GameResult.lose]! > 0) {
      return Colors.white;
    }

    return AppColors.black;
  }

  /// 경기 수 배지 위젯 생성
  Widget _buildGameCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 특별 경기 표시 위젯 생성
  Widget _buildSpecialGameIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }

  /// 경기 결과 분석
  Map<GameResult, int> _analyzeGameResults(List<GameRecord> records) {
    final results = <GameResult, int>{};

    for (final record in records) {
      if (!record.canceled) {
        final result = record.result;
        results[result] = (results[result] ?? 0) + 1;
      }
    }

    return results;
  }

  /// 특별 경기 여부 확인 (즐겨찾기 기록이 있는지)
  bool _hasSpecialGames(List<GameRecord> records) {
    return records.any((record) => record.isFavorite);
  }

  /// 날짜 선택 처리
  void _selectDate(DateTime date) {
    widget.onDateSelected(date);

    // 선택 애니메이션
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // 햅틱 피드백
    HapticFeedback.selectionClick();
  }

  /// 날짜 롱프레스 처리
  void _longPressDate(DateTime date) {
    setState(() {
      _longPressedDate = date;
    });

    // 햅틱 피드백
    HapticFeedback.mediumImpact();

    // 롱프레스 액션 메뉴 표시
    _showDateActionMenu(date);
  }

  /// 롱프레스 종료 처리
  void _endLongPress() {
    setState(() {
      _longPressedDate = null;
    });
  }

  /// 날짜 액션 메뉴 표시
  void _showDateActionMenu(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final dayRecords = widget.scheduleMap[dateKey] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DateActionMenu(
            date: date,
            records: dayRecords,
            onAddRecord: () {
              Navigator.pop(context);
              // TODO: 직관 기록 추가 화면으로 이동
            },
            onViewSchedule: () {
              Navigator.pop(context);
              widget.onDateSelected(date);
            },
          ),
    );
  }
}

/// 날짜 액션 메뉴 위젯
class DateActionMenu extends StatelessWidget {
  final DateTime date;
  final List<GameRecord> records;
  final VoidCallback onAddRecord;
  final VoidCallback onViewSchedule;

  const DateActionMenu({
    Key? key,
    required this.date,
    required this.records,
    required this.onAddRecord,
    required this.onViewSchedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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

            // 날짜 헤더
            Text(
              dateFormat.format(date),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            if (records.isNotEmpty)
              Text(
                '${records.length}개의 직관 기록',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70),
              ),

            const SizedBox(height: 24),

            // 액션 버튼들
            _buildActionItem(
              context,
              icon: Icons.add_circle_outline,
              title: '직관 기록 추가',
              subtitle: '이 날의 경기 기록을 추가합니다',
              onTap: onAddRecord,
            ),

            if (records.isNotEmpty)
              _buildActionItem(
                context,
                icon: Icons.event_note_outlined,
                title: '직관 기록 보기',
                subtitle: '이 날의 직관 기록을 확인합니다',
                onTap: onViewSchedule,
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 액션 아이템 위젯 생성
  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.navy5,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.navy, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.gray70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray50),
          ],
        ),
      ),
    );
  }
}
