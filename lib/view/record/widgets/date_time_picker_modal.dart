import 'package:flutter/material.dart';
import 'package:seungyo/theme/theme.dart';

class DateTimePickerModal extends StatefulWidget {
  final DateTime? initialDateTime;
  final Function(DateTime) onDateTimeSelected;

  const DateTimePickerModal({
    Key? key,
    this.initialDateTime,
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  State<DateTimePickerModal> createState() => _DateTimePickerModalState();
}

class _DateTimePickerModalState extends State<DateTimePickerModal> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late DateTime _currentMonth;

  final List<String> _timeSlots = ['14:00', '17:00', '18:30'];
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    final now = widget.initialDateTime ?? DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedTime = TimeOfDay.fromDateTime(now);
    _currentMonth = DateTime(now.year, now.month);
    _selectedTimeSlot = _timeSlots.first;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(colorScheme, textTheme),
          Expanded(
            child: Column(
              children: [
                _buildCalendarHeader(textTheme),
                _buildCalendar(colorScheme, textTheme),
                _buildTimeSelection(colorScheme, textTheme),
                _buildConfirmButton(colorScheme, textTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('관람한 날짜&시간', style: textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
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
            style: textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
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
      ),
    );
  }

  Widget _buildCalendar(ColorScheme colorScheme, TextTheme textTheme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildWeekdayHeaders(textTheme),
            Expanded(child: _buildCalendarGrid(colorScheme, textTheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders(TextTheme textTheme) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      children:
          weekdays
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.gray70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCalendarGrid(ColorScheme colorScheme, TextTheme textTheme) {
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

    // Previous month's trailing days
    for (int i = 0; i < firstDayWeekday; i++) {
      final day = DateTime(
        _currentMonth.year,
        _currentMonth.month,
        -firstDayWeekday + i + 1,
      );
      days.add(_buildCalendarDay(day, true, colorScheme, textTheme));
    }

    // Current month's days
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      days.add(_buildCalendarDay(date, false, colorScheme, textTheme));
    }

    // Next month's leading days
    final remainingDays = 42 - days.length;
    for (int day = 1; day <= remainingDays; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month + 1, day);
      days.add(_buildCalendarDay(date, true, colorScheme, textTheme));
    }

    return GridView.count(crossAxisCount: 7, children: days);
  }

  Widget _buildCalendarDay(
    DateTime date,
    bool isOtherMonth,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected =
        _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mint : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: textTheme.bodyMedium?.copyWith(
              color:
                  isOtherMonth
                      ? AppColors.gray30
                      : isSelected
                      ? AppColors.navy
                      : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelection(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            _timeSlots.map((time) {
              final isSelected = _selectedTimeSlot == time;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeSlot = time;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.mint : AppColors.gray10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    time,
                    style: textTheme.bodyLarge?.copyWith(
                      color:
                          isSelected ? AppColors.navy : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildConfirmButton(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            final timeParts = _selectedTimeSlot!.split(':');
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
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '선택 완료',
            style: AppTextStyles.button1.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
