import 'package:flutter/material.dart';
import 'package:seungyo/theme/theme.dart';
import 'package:seungyo/models/game_schedule.dart';

class DateTimePickerModal extends StatefulWidget {
  final DateTime? initialDateTime;
  final Function(DateTime) onDateTimeSelected;
  final List<GameSchedule>? gameSchedules; // 경기 일정 데이터

  const DateTimePickerModal({
    Key? key,
    this.initialDateTime,
    required this.onDateTimeSelected,
    this.gameSchedules,
  }) : super(key: key);

  @override
  State<DateTimePickerModal> createState() => _DateTimePickerModalState();
}

class _DateTimePickerModalState extends State<DateTimePickerModal> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  String _selectedTimeSlot = '14:00';

  final List<String> _timeSlots = ['14:00', '17:00', '18:30'];

  @override
  void initState() {
    super.initState();
    final now = widget.initialDateTime ?? DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month);

    // 초기화 후 사용 가능한 시간으로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedTimeSlot();
    });
  }

  /// 선택된 날짜에 사용 가능한 첫 번째 시간으로 업데이트
  void _updateSelectedTimeSlot() {
    final availableTimes = _getAvailableTimesForDate(_selectedDate);
    if (availableTimes.isNotEmpty) {
      if (!availableTimes.contains(_selectedTimeSlot)) {
        setState(() {
          _selectedTimeSlot = availableTimes.first;
        });
      }
    }
  }

  /// 해당 날짜에 경기가 있는지 확인
  bool _hasGameOnDate(DateTime date) {
    if (widget.gameSchedules == null || widget.gameSchedules!.isEmpty) {
      return false; // 경기 데이터가 없으면 모든 날짜 비활성화
    }

    return widget.gameSchedules!.any((game) {
      final gameDate = game.dateTime;
      return gameDate.year == date.year &&
          gameDate.month == date.month &&
          gameDate.day == date.day;
    });
  }

  /// 현재 월에서 특정 요일에 경기가 있는지 확인
  bool _hasGameOnWeekdayInMonth(int weekday) {
    if (widget.gameSchedules == null || widget.gameSchedules!.isEmpty) {
      return false; // 경기 데이터가 없으면 모든 요일 비활성화
    }

    return widget.gameSchedules!.any((game) {
      final gameDate = game.dateTime;
      return gameDate.year == _currentMonth.year &&
          gameDate.month == _currentMonth.month &&
          gameDate.weekday == weekday;
    });
  }

  /// 특정 날짜에 사용 가능한 시간 슬롯들 반환
  List<String> _getAvailableTimesForDate(DateTime date) {
    if (widget.gameSchedules == null || widget.gameSchedules!.isEmpty) {
      return []; // 경기 데이터가 없으면 모든 시간 비활성화
    }

    final gamesOnDate =
        widget.gameSchedules!.where((game) {
          final gameDate = game.dateTime;
          return gameDate.year == date.year &&
              gameDate.month == date.month &&
              gameDate.day == date.day;
        }).toList();

    final availableTimes = <String>[];

    for (final timeSlot in _timeSlots) {
      final timeParts = timeSlot.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // 해당 시간에 경기가 있는지 확인
      final hasGameAtTime = gamesOnDate.any((game) {
        return game.dateTime.hour == hour && game.dateTime.minute == minute;
      });

      if (hasGameAtTime) {
        availableTimes.add(timeSlot);
      }
    }

    return availableTimes;
  }

  /// 특정 시간이 선택된 날짜에 사용 가능한지 확인
  bool _isTimeAvailable(String timeSlot) {
    return _getAvailableTimesForDate(_selectedDate).contains(timeSlot);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildCalendarSection()),
          _buildTimeSelection(),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '관람한 날짜&시간',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMonthNavigation(),
          const SizedBox(height: 20),
          _buildWeekdayHeaders(),
          const SizedBox(height: 10),
          Expanded(child: _buildCalendarGrid()),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.gray50,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
            });
          },
        ),
        Text(
          '${_currentMonth.year}년 ${_currentMonth.month}월',
          style: AppTextStyles.body1.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Transform.rotate(
            angle: 3.14159,
            child: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.gray50,
              size: 20,
            ),
          ),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      children:
          weekdays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isWeekend = index == 0 || index == 6;

            // 요일별 경기 존재 여부 확인 (일요일=7, 월요일=1, ... 토요일=6)
            final weekdayNumber = index == 0 ? 7 : index; // 일요일을 7로 변환
            final hasGamesOnWeekday = _hasGameOnWeekdayInMonth(weekdayNumber);

            Color textColor;
            if (!hasGamesOnWeekday) {
              textColor = AppColors.gray50; // 경기가 없는 요일은 비활성화
            } else if (isWeekend) {
              textColor = AppColors.black; // 주말
            } else {
              textColor = AppColors.gray50; // 평일
            }

            return Expanded(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: AppTextStyles.body1.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday % 7;

    final days = <Widget>[];

    // 이전 달 날짜들
    for (int i = 0; i < firstDayWeekday; i++) {
      final day = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        -firstDayWeekday + i + 1,
      );
      days.add(_buildCalendarDay(day, true));
    }

    // 현재 달 날짜들
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      days.add(_buildCalendarDay(date, false));
    }

    // 다음 달 날짜들
    final remainingDays = 42 - days.length;
    for (int day = 1; day <= remainingDays; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month + 1, day);
      days.add(_buildCalendarDay(date, true));
    }

    return GridView.count(crossAxisCount: 7, children: days);
  }

  Widget _buildCalendarDay(DateTime date, bool isOtherMonth) {
    final isSelected =
        _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;
    final isToday =
        DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;
    final hasGame = _hasGameOnDate(date);
    final isDisabled = !hasGame && !isOtherMonth;

    Color? backgroundColor;
    Color? borderColor;
    Color textColor = AppColors.black;
    FontWeight fontWeight = FontWeight.w500;

    if (isOtherMonth) {
      textColor = AppColors.gray50;
    } else if (isDisabled) {
      textColor = AppColors.gray50;
    } else if (isSelected) {
      backgroundColor = AppColors.mint;
      borderColor = AppColors.mint60;
      textColor = AppColors.black;
      fontWeight = FontWeight.w700;
    } else if (isToday) {
      borderColor = AppColors.mint;
      textColor = AppColors.black;
    }

    return GestureDetector(
      onTap:
          (isOtherMonth || isDisabled)
              ? null
              : () {
                setState(() {
                  _selectedDate = date;
                  _updateSelectedTimeSlot(); // 날짜 변경 시 시간 슬롯 업데이트
                });
              },
      child: Container(
        margin: const EdgeInsets.all(2),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          border:
              borderColor != null
                  ? Border.all(color: borderColor, width: 1)
                  : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: AppTextStyles.body1.copyWith(
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 1,
            color: AppColors.gray20,
            margin: const EdgeInsets.only(bottom: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                _timeSlots.map((time) {
                  final isSelected = _selectedTimeSlot == time;
                  final isAvailable = _isTimeAvailable(time);

                  return GestureDetector(
                    onTap:
                        isAvailable
                            ? () {
                              setState(() {
                                _selectedTimeSlot = time;
                              });
                            }
                            : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            !isAvailable
                                ? AppColors.gray10
                                : isSelected
                                ? AppColors.mint
                                : AppColors.gray10,
                        border:
                            !isAvailable
                                ? Border.all(color: AppColors.gray20, width: 1)
                                : isSelected
                                ? Border.all(color: AppColors.mint60, width: 1)
                                : Border.all(color: AppColors.gray20, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        time,
                        style: AppTextStyles.body1.copyWith(
                          color:
                              !isAvailable ? AppColors.gray50 : AppColors.navy,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final hasAvailableTime =
        _getAvailableTimesForDate(_selectedDate).isNotEmpty;
    final isSelectedTimeAvailable = _isTimeAvailable(_selectedTimeSlot);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed:
              (hasAvailableTime && isSelectedTimeAvailable)
                  ? () {
                    final timeParts = _selectedTimeSlot.split(':');
                    final hour = int.parse(timeParts[0]);
                    final minute = int.parse(timeParts[1]);

                    final selectedDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      hour,
                      minute,
                    );

                    widget.onDateTimeSelected(selectedDateTime);
                    Navigator.pop(context);
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                (hasAvailableTime && isSelectedTimeAvailable)
                    ? AppColors.navy
                    : AppColors.gray20,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            '선택 완료',
            style: AppTextStyles.body1.copyWith(
              color:
                  (hasAvailableTime && isSelectedTimeAvailable)
                      ? Colors.white
                      : AppColors.gray50,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
