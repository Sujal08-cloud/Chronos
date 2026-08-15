import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_time_helper.dart';
import '../../../todo/domain/todo_model.dart';

class MonthCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<TodoModel> allTodos;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  const MonthCalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.allTodos,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  List<TodoModel> _todosForDay(DateTime day) {
    return allTodos
        .where(
          (t) => DateTimeHelper.isSameDay(
            t.scheduledDate,
            day,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.colorScheme.surface;

    final textColor = isDark
        ? Colors.white
        : Colors.black87;

    final mutedTextColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.50);

    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMd),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingSm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          AppSizes.radiusMd,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.25 : 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),

      child: TableCalendar<TodoModel>(
        firstDay: DateTime.now(),
        lastDay: DateTime.utc(2030, 12, 31),

        focusedDay: focusedDay,

        selectedDayPredicate: (day) {
          return DateTimeHelper.isSameDay(
            day,
            selectedDay,
          );
        },

        eventLoader: _todosForDay,

        calendarFormat: CalendarFormat.month,

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,

          titleTextStyle: TextStyle(
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),

          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: textColor,
          ),

          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: textColor,
          ),
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: mutedTextColor,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: mutedTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),

        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),

          weekendTextStyle: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),

          outsideTextStyle: TextStyle(
            color: mutedTextColor,
          ),

          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),

          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),

          todayDecoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),

          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),

          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),

          markersMaxCount: 3,

          outsideDaysVisible: false,

          cellMargin: const EdgeInsets.all(4),
        ),

        onDaySelected: (selected, focused) {
          onDaySelected(selected);
        },

        onPageChanged: onPageChanged,
      ),
    );
  }
}