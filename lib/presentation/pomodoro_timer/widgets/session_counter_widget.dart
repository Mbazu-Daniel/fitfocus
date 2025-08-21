import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SessionCounterWidget extends StatelessWidget {
  final int currentSession;
  final int totalSessions;

  const SessionCounterWidget({
    super.key,
    required this.currentSession,
    required this.totalSessions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'Session ${currentSession} of ${totalSessions}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 2.h),

        // Session dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSessions, (index) {
            final isCompleted = index < currentSession;
            final isCurrent = index == currentSession - 1;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: isCurrent ? 3.w : 2.w,
              height: isCurrent ? 3.w : 2.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? theme.colorScheme.primary
                    : isCurrent
                        ? theme.colorScheme.primary.withValues(alpha: 0.7)
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
