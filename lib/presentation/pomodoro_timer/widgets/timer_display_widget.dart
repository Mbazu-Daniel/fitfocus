import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TimerDisplayWidget extends StatelessWidget {
  final Duration remainingTime;
  final Duration totalTime;
  final bool isActive;
  final String sessionType;

  const TimerDisplayWidget({
    super.key,
    required this.remainingTime,
    required this.totalTime,
    required this.isActive,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalTime.inSeconds > 0
        ? (totalTime.inSeconds - remainingTime.inSeconds) / totalTime.inSeconds
        : 0.0;

    return Container(
      width: 70.w,
      height: 70.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  offset: Offset(0, 4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),

          // Progress ring
          SizedBox(
            width: 70.w,
            height: 70.w,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                sessionType == 'Work'
                    ? theme.colorScheme.primary
                    : AppTheme.successLight,
              ),
            ),
          ),

          // Timer content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Session type indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: (sessionType == 'Work'
                          ? theme.colorScheme.primary
                          : AppTheme.successLight)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sessionType,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: sessionType == 'Work'
                        ? theme.colorScheme.primary
                        : AppTheme.successLight,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // Timer display
              Text(
                _formatTime(remainingTime),
                style: AppTheme.timerDisplayStyle(
                  isLight: theme.brightness == Brightness.light,
                ).copyWith(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              SizedBox(height: 1.h),

              // Status indicator
              if (isActive)
                Container(
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sessionType == 'Work'
                        ? theme.colorScheme.primary
                        : AppTheme.successLight,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
