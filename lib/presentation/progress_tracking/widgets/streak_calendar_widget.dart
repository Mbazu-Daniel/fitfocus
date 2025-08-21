import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StreakCalendarWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> streakData;
  final DateTime currentDate;

  const StreakCalendarWidget({
    super.key,
    required this.title,
    required this.streakData,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'local_fire_department',
                      color: AppTheme.successLight,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${_getCurrentStreak()} days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.successLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildCalendarGrid(context),
          SizedBox(height: 2.h),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get the start of the current month
    final startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final endOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    final daysInMonth = endOfMonth.day;
    final startWeekday = startOfMonth.weekday;

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
            return SizedBox(
              width: 10.w,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 1.h),
        // Calendar grid
        ...List.generate((daysInMonth + startWeekday - 1) ~/ 7 + 1,
            (weekIndex) {
          return Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - startWeekday + 2;

                if (dayNumber <= 0 || dayNumber > daysInMonth) {
                  return SizedBox(width: 10.w, height: 10.w);
                }

                final date =
                    DateTime(currentDate.year, currentDate.month, dayNumber);
                final streakLevel = _getStreakLevel(date);

                return _buildCalendarDay(context, dayNumber, streakLevel, date);
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCalendarDay(
      BuildContext context, int day, int streakLevel, DateTime date) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    Color backgroundColor;
    Color textColor = colorScheme.onSurface;

    switch (streakLevel) {
      case 0:
        backgroundColor = colorScheme.surface;
        textColor = colorScheme.onSurface.withValues(alpha: 0.3);
        break;
      case 1:
        backgroundColor = AppTheme.successLight.withValues(alpha: 0.2);
        break;
      case 2:
        backgroundColor = AppTheme.successLight.withValues(alpha: 0.5);
        textColor = Colors.white;
        break;
      case 3:
        backgroundColor = AppTheme.successLight;
        textColor = Colors.white;
        break;
      default:
        backgroundColor = colorScheme.surface;
    }

    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border:
            isToday ? Border.all(color: colorScheme.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(width: 2.w),
        ...List.generate(4, (index) {
          Color color;
          switch (index) {
            case 0:
              color = colorScheme.outline.withValues(alpha: 0.2);
              break;
            case 1:
              color = AppTheme.successLight.withValues(alpha: 0.2);
              break;
            case 2:
              color = AppTheme.successLight.withValues(alpha: 0.5);
              break;
            case 3:
              color = AppTheme.successLight;
              break;
            default:
              color = colorScheme.outline.withValues(alpha: 0.2);
          }

          return Container(
            width: 3.w,
            height: 3.w,
            margin: EdgeInsets.symmetric(horizontal: 0.5.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        SizedBox(width: 2.w),
        Text(
          'More',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  int _getStreakLevel(DateTime date) {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final dayData = streakData.firstWhere(
      (data) => data['date'] == dateString,
      orElse: () => {'sessions': 0},
    );

    final sessions = dayData['sessions'] as int;
    if (sessions == 0) return 0;
    if (sessions <= 2) return 1;
    if (sessions <= 4) return 2;
    return 3;
  }

  int _getCurrentStreak() {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final dateString =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      final dayData = streakData.firstWhere(
        (data) => data['date'] == dateString,
        orElse: () => {'sessions': 0},
      );

      if ((dayData['sessions'] as int) > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
