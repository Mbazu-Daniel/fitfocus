import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ExerciseInfoWidget extends StatelessWidget {
  final String title;
  final String difficulty;
  final String duration;
  final String category;

  const ExerciseInfoWidget({
    super.key,
    required this.title,
    required this.difficulty,
    required this.duration,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20.sp,
                ),
          ),

          SizedBox(height: 2.h),

          // Exercise metadata
          Row(
            children: [
              // Difficulty badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getDifficultyColor(difficulty),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _getDifficultyIcon(difficulty),
                      color: _getDifficultyColor(difficulty),
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      difficulty,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getDifficultyColor(difficulty),
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 3.w),

              // Duration info
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 3.w),

              // Category info
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'category',
                      color: AppTheme.accentLight,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentLight,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.successLight;
      case 'intermediate':
        return AppTheme.warningLight;
      case 'advanced':
        return AppTheme.errorLight;
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  String _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'trending_up';
      case 'intermediate':
        return 'show_chart';
      case 'advanced':
        return 'whatshot';
      default:
        return 'fitness_center';
    }
  }
}
