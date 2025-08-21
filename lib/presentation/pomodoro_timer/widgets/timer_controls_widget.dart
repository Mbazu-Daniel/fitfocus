import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TimerControlsWidget extends StatelessWidget {
  final bool isActive;
  final bool isPaused;
  final VoidCallback onStartPause;
  final VoidCallback onStop;
  final VoidCallback onSkip;
  final VoidCallback onSettings;

  const TimerControlsWidget({
    super.key,
    required this.isActive,
    required this.isPaused,
    required this.onStartPause,
    required this.onStop,
    required this.onSkip,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Primary action button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onStartPause();
          },
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: CustomIconWidget(
              iconName: isActive && !isPaused ? 'pause' : 'play_arrow',
              color: theme.colorScheme.onPrimary,
              size: 8.w,
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Secondary controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Stop button
            if (isActive)
              _buildSecondaryButton(
                context: context,
                icon: 'stop',
                onTap: () {
                  HapticFeedback.lightImpact();
                  onStop();
                },
                tooltip: 'Stop Timer',
              ),

            // Skip button
            if (isActive)
              _buildSecondaryButton(
                context: context,
                icon: 'skip_next',
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSkip();
                },
                tooltip: 'Skip Session',
              ),

            // Settings button
            _buildSecondaryButton(
              context: context,
              icon: 'settings',
              onTap: () {
                HapticFeedback.lightImpact();
                onSettings();
              },
              tooltip: 'Timer Settings',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required String icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            size: 5.w,
          ),
        ),
      ),
    );
  }
}
