import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/exercise_info_widget.dart';
import './widgets/exercise_tabs_widget.dart';
import './widgets/timer_selection_widget.dart';
import './widgets/video_player_widget.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({super.key});

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  bool _isBookmarked = false;
  int _selectedDuration = 60;
  bool _isExerciseStarted = false;
  int _countdown = 0;

  // Mock exercise data
  final Map<String, dynamic> exerciseData = {
    "id": 1,
    "title": "Desk Shoulder Rolls",
    "difficulty": "Beginner",
    "duration": "2-3 min",
    "category": "Neck & Shoulders",
    "videoUrl":
        "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "description":
        "Perfect exercise to relieve shoulder tension from prolonged desk work. Helps improve posture and reduce stiffness.",
    "instructions": [
      "Sit up straight in your chair with feet flat on the floor",
      "Relax your arms at your sides and let your shoulders drop naturally",
      "Slowly roll your shoulders forward in a circular motion 5 times",
      "Reverse the direction and roll your shoulders backward 5 times",
      "Focus on making smooth, controlled movements",
      "Breathe deeply throughout the exercise",
      "Repeat the sequence 2-3 times for maximum benefit"
    ],
    "benefits": [
      "Reduces shoulder and neck tension from desk work",
      "Improves blood circulation in the upper body",
      "Helps correct forward head posture",
      "Relieves muscle stiffness and knots",
      "Increases range of motion in shoulder joints",
      "Prevents repetitive strain injuries",
      "Boosts energy and mental alertness"
    ],
    "equipment": [],
    "targetMuscles": ["Shoulders", "Upper Trapezius", "Rhomboids"],
    "caloriesBurned": 5,
    "isBookmarked": false
  };

  @override
  void initState() {
    super.initState();
    _isBookmarked = exerciseData["isBookmarked"] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body:
          _isExerciseStarted ? _buildExerciseTimer() : _buildExerciseContent(),
      bottomNavigationBar: _isExerciseStarted ? null : _buildActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'arrow_back_ios',
          color: Theme.of(context).colorScheme.onSurface,
          size: 5.w,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Exercise Detail',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: _isBookmarked ? 'bookmark' : 'bookmark_border',
            color: _isBookmarked
                ? AppTheme.warningLight
                : Theme.of(context).colorScheme.onSurface,
            size: 5.w,
          ),
          onPressed: _toggleBookmark,
        ),
        IconButton(
          icon: CustomIconWidget(
            iconName: 'share',
            color: Theme.of(context).colorScheme.onSurface,
            size: 5.w,
          ),
          onPressed: _handleShare,
        ),
      ],
    );
  }

  Widget _buildExerciseContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player section
          Container(
            padding: EdgeInsets.all(4.w),
            child: VideoPlayerWidget(
              videoUrl: exerciseData["videoUrl"],
              exerciseTitle: exerciseData["title"],
            ),
          ),

          // Exercise info section
          ExerciseInfoWidget(
            title: exerciseData["title"],
            difficulty: exerciseData["difficulty"],
            duration: exerciseData["duration"],
            category: exerciseData["category"],
          ),

          SizedBox(height: 2.h),

          // Timer selection
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: TimerSelectionWidget(
              selectedDuration: _selectedDuration,
              onDurationSelected: (duration) {
                setState(() {
                  _selectedDuration = duration;
                });
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Exercise tabs
          ExerciseTabsWidget(
            instructions: (exerciseData["instructions"] as List).cast<String>(),
            benefits: (exerciseData["benefits"] as List).cast<String>(),
            equipment: (exerciseData["equipment"] as List).cast<String>(),
          ),

          SizedBox(height: 10.h), // Space for bottom buttons
        ],
      ),
    );
  }

  Widget _buildExerciseTimer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Exercise title
          Text(
            exerciseData["title"],
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 22.sp,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Timer display
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                  offset: Offset(0, 4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTimerDisplay(_countdown),
                    style: AppTheme.timerDisplayStyle(isLight: true).copyWith(
                      fontSize: 32.sp,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'seconds',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          fontSize: 12.sp,
                        ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stop button
              SizedBox(
                width: 35.w,
                height: 6.h,
                child: OutlinedButton(
                  onPressed: _stopExercise,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorLight,
                    side: BorderSide(color: AppTheme.errorLight, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'stop',
                        color: AppTheme.errorLight,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Stop',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.errorLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Complete button
              SizedBox(
                width: 35.w,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _completeExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Complete',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return ActionButtonsWidget(
      onStartExercise: _startExercise,
      onAddToRoutine: _addToRoutine,
      isBookmarked: _isBookmarked,
      onBookmarkToggle: _toggleBookmark,
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Exercise bookmarked' : 'Bookmark removed',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleShare() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exercise shared successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startExercise() {
    setState(() {
      _isExerciseStarted = true;
      _countdown = _selectedDuration;
    });

    _startCountdown();
  }

  void _startCountdown() {
    if (_countdown > 0 && _isExerciseStarted) {
      Future.delayed(Duration(seconds: 1), () {
        if (mounted && _isExerciseStarted) {
          setState(() {
            _countdown--;
          });
          _startCountdown();
        }
      });
    } else if (_countdown == 0 && _isExerciseStarted) {
      _completeExercise();
    }
  }

  void _stopExercise() {
    setState(() {
      _isExerciseStarted = false;
      _countdown = 0;
    });

    HapticFeedback.mediumImpact();
  }

  void _completeExercise() {
    setState(() {
      _isExerciseStarted = false;
      _countdown = 0;
    });

    HapticFeedback.heavyImpact();

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: AppTheme.successLight,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Great Job!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You completed the ${exerciseData["title"]} exercise!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp,
                  ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'local_fire_department',
                    color: AppTheme.warningLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${exerciseData["caloriesBurned"]} calories burned',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/progress-tracking');
            },
            child: Text('View Progress'),
          ),
        ],
      ),
    );
  }

  void _addToRoutine() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exercise added to your routine'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to routine view
          },
        ),
      ),
    );
  }

  String _formatTimerDisplay(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
