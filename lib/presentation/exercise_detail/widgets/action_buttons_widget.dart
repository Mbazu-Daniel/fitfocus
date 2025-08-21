import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ActionButtonsWidget extends StatefulWidget {
  final VoidCallback onStartExercise;
  final VoidCallback onAddToRoutine;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const ActionButtonsWidget({
    super.key,
    required this.onStartExercise,
    required this.onAddToRoutine,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Primary action button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isStarting ? null : _handleStartExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isStarting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Starting...',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'play_arrow',
                            color: Colors.white,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Start Exercise',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                          ),
                        ],
                      ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary actions
            Row(
              children: [
                // Add to routine button
                Expanded(
                  child: SizedBox(
                    height: 5.h,
                    child: OutlinedButton(
                      onPressed: widget.onAddToRoutine,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.lightTheme.primaryColor,
                        side: BorderSide(
                          color: AppTheme.lightTheme.primaryColor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'add_circle_outline',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Add to Routine',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.lightTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // Bookmark button
                SizedBox(
                  width: 12.w,
                  height: 5.h,
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onBookmarkToggle();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.isBookmarked
                          ? AppTheme.warningLight
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                      side: BorderSide(
                        color: widget.isBookmarked
                            ? AppTheme.warningLight
                            : Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: CustomIconWidget(
                      iconName:
                          widget.isBookmarked ? 'bookmark' : 'bookmark_border',
                      color: widget.isBookmarked
                          ? AppTheme.warningLight
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // Share button
                SizedBox(
                  width: 12.w,
                  height: 5.h,
                  child: OutlinedButton(
                    onPressed: _handleShare,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      side: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: CustomIconWidget(
                      iconName: 'share',
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleStartExercise() async {
    setState(() {
      _isStarting = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate exercise preparation
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isStarting = false;
      });

      widget.onStartExercise();
    }
  }

  void _handleShare() {
    HapticFeedback.lightImpact();

    // Show share options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Share Exercise',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption('copy', 'Copy Link', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Exercise link copied to clipboard')),
                  );
                }),
                _buildShareOption('message', 'Message', () {
                  Navigator.pop(context);
                }),
                _buildShareOption('email', 'Email', () {
                  Navigator.pop(context);
                }),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(String iconName, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11.sp,
                ),
          ),
        ],
      ),
    );
  }
}
