import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';

class PostureExercisesScreen extends StatefulWidget {
  const PostureExercisesScreen({Key? key}) : super(key: key);

  @override
  State<PostureExercisesScreen> createState() => _PostureExercisesScreenState();
}

class _PostureExercisesScreenState extends State<PostureExercisesScreen>
    with TickerProviderStateMixin {
  late AnimationController _reminderAnimationController;
  late Animation<double> _reminderAnimation;

  bool _postureRemindersEnabled = true;
  int _reminderInterval = 30; // minutes
  Timer? _postureReminderTimer;
  DateTime? _lastPostureReminder;
  int _dailyExercisesCompleted = 0;
  int _dailyExerciseGoal = 5;

  // Posture exercise categories
  final List<Map<String, dynamic>> _exerciseCategories = [
    {
      'name': 'Desk Stretches',
      'description': 'Quick stretches you can do at your desk',
      'icon': Icons.desk,
      'color': Colors.blue,
      'exercises': [
        {
          'name': 'Neck Rolls',
          'duration': 30,
          'description': 'Slowly roll your neck in circles to release tension',
          'instructions': [
            'Sit up straight in your chair',
            'Drop your right ear toward your right shoulder',
            'Slowly roll your head down to center',
            'Continue to the left shoulder',
            'Roll back to center and repeat',
          ],
          'benefits': 'Relieves neck tension and improves flexibility',
        },
        {
          'name': 'Shoulder Blade Squeezes',
          'duration': 15,
          'description': 'Strengthen upper back muscles',
          'instructions': [
            'Sit up tall with arms at your sides',
            'Squeeze shoulder blades together',
            'Hold for 5 seconds',
            'Release and repeat',
          ],
          'benefits': 'Counteracts forward head posture',
        },
        {
          'name': 'Seated Spinal Twist',
          'duration': 30,
          'description': 'Rotate spine to improve mobility',
          'instructions': [
            'Sit up straight, feet flat on floor',
            'Place right hand on left knee',
            'Twist gently to the left',
            'Hold and breathe deeply',
            'Repeat on other side',
          ],
          'benefits': 'Improves spinal mobility and reduces stiffness',
        },
      ],
    },
    {
      'name': 'Standing Breaks',
      'description': 'Exercises to do during standing breaks',
      'icon': Icons.accessibility_new,
      'color': Colors.green,
      'exercises': [
        {
          'name': 'Wall Push-Ups',
          'duration': 60,
          'description': 'Strengthen chest and improve posture',
          'instructions': [
            'Stand arm\'s length from a wall',
            'Place palms flat against wall',
            'Lean in toward wall',
            'Push back to starting position',
            'Repeat 10-15 times',
          ],
          'benefits': 'Strengthens chest muscles and improves upper body posture',
        },
        {
          'name': 'Standing Forward Fold',
          'duration': 30,
          'description': 'Stretch spine and hamstrings',
          'instructions': [
            'Stand with feet hip-width apart',
            'Slowly bend forward from hips',
            'Let arms hang toward floor',
            'Hold and breathe deeply',
            'Slowly roll up to standing',
          ],
          'benefits': 'Relieves lower back tension and stretches hamstrings',
        },
        {
          'name': 'Calf Raises',
          'duration': 30,
          'description': 'Improve circulation and strengthen calves',
          'instructions': [
            'Stand with feet hip-width apart',
            'Rise up onto balls of feet',
            'Hold for 2 seconds',
            'Lower slowly',
            'Repeat 15-20 times',
          ],
          'benefits': 'Improves circulation and strengthens lower legs',
        },
      ],
    },
    {
      'name': 'Floor Exercises',
      'description': 'Exercises requiring floor space',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
      'exercises': [
        {
          'name': 'Cat-Cow Stretch',
          'duration': 60,
          'description': 'Improve spinal flexibility',
          'instructions': [
            'Start on hands and knees',
            'Arch back and look up (Cow)',
            'Round spine toward ceiling (Cat)',
            'Alternate slowly between positions',
            'Breathe deeply with each movement',
          ],
          'benefits': 'Improves spinal flexibility and relieves back tension',
        },
        {
          'name': 'Child\'s Pose',
          'duration': 60,
          'description': 'Relax and stretch back muscles',
          'instructions': [
            'Kneel on floor, touch big toes together',
            'Sit back on heels',
            'Reach arms forward on floor',
            'Rest forehead on ground',
            'Breathe deeply and relax',
          ],
          'benefits': 'Relieves stress and gently stretches back muscles',
        },
        {
          'name': 'Hip Flexor Stretch',
          'duration': 45,
          'description': 'Counteract tight hip flexors from sitting',
          'instructions': [
            'Step right foot forward into lunge',
            'Lower left knee to ground',
            'Push hips forward gently',
            'Hold and feel stretch in left hip',
            'Switch sides and repeat',
          ],
          'benefits': 'Reduces hip tightness and improves posture',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPostureData();
    _setupPostureReminders();
  }

  void _initializeAnimations() {
    _reminderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _reminderAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _reminderAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadPostureData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    
    setState(() {
      _postureRemindersEnabled = prefs.getBool('posture_reminders') ?? true;
      _reminderInterval = prefs.getInt('posture_reminder_interval') ?? 30;
      _dailyExercisesCompleted = prefs.getInt('exercises_completed_$today') ?? 0;
      _dailyExerciseGoal = prefs.getInt('daily_exercise_goal') ?? 5;
    });
  }

  Future<void> _savePostureData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    
    await prefs.setBool('posture_reminders', _postureRemindersEnabled);
    await prefs.setInt('posture_reminder_interval', _reminderInterval);
    await prefs.setInt('exercises_completed_$today', _dailyExercisesCompleted);
    await prefs.setInt('daily_exercise_goal', _dailyExerciseGoal);
  }

  void _setupPostureReminders() {
    if (_postureRemindersEnabled) {
      _postureReminderTimer = Timer.periodic(
        Duration(minutes: _reminderInterval),
        (timer) => _showPostureReminder(),
      );
    }
  }

  void _showPostureReminder() {
    final now = DateTime.now();
    
    // Don't remind too frequently or outside work hours
    if (_lastPostureReminder != null &&
        now.difference(_lastPostureReminder!).inMinutes < _reminderInterval) {
      return;
    }
    
    if (now.hour < 8 || now.hour > 18) return; // Work hours only
    
    _lastPostureReminder = now;
    
    if (mounted) {
      _reminderAnimationController.repeat(reverse: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.accessibility_new, color: Colors.orange),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Posture check! 🧘 Time for a quick stretch.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Stretch',
            onPressed: () => _showQuickExerciseDialog(),
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 5),
        ),
      );
      
      // Stop animation after notification
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          _reminderAnimationController.stop();
          _reminderAnimationController.reset();
        }
      });
    }
  }

  void _showQuickExerciseDialog() {
    final quickExercises = [
      _exerciseCategories[0]['exercises'][0], // Neck Rolls
      _exerciseCategories[0]['exercises'][1], // Shoulder Blade Squeezes
      _exerciseCategories[1]['exercises'][1], // Standing Forward Fold
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Posture Break'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: quickExercises.map((exercise) => ListTile(
            leading: Icon(Icons.fitness_center, color: Colors.orange),
            title: Text(exercise['name']),
            subtitle: Text('${exercise['duration']}s - ${exercise['description']}'),
            onTap: () {
              Navigator.pop(context);
              _startExercise(exercise);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _startExercise(Map<String, dynamic> exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailScreen(
          exercise: exercise,
          onComplete: () {
            setState(() {
              _dailyExercisesCompleted++;
            });
            _savePostureData();
            
            if (_dailyExercisesCompleted >= _dailyExerciseGoal) {
              _showGoalAchievedDialog();
            }
          },
        ),
      ),
    );
  }

  void _showGoalAchievedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 2.w),
            Text('Daily Goal Achieved!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Colors.amber,
            ),
            SizedBox(height: 2.h),
            Text(
              'Great job! You\'ve completed $_dailyExerciseGoal posture exercises today. Your body will thank you!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Excellent!'),
          ),
        ],
      ),
    );
  }

  void _configureReminders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Posture Reminder Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Enable Posture Reminders'),
              subtitle: Text('Get reminded to check your posture'),
              value: _postureRemindersEnabled,
              onChanged: (value) {
                setState(() {
                  _postureRemindersEnabled = value;
                });
                if (value) {
                  _setupPostureReminders();
                } else {
                  _postureReminderTimer?.cancel();
                }
                _savePostureData();
              },
            ),
            if (_postureRemindersEnabled) ...[
              SizedBox(height: 2.h),
              Text('Remind every:'),
              Wrap(
                spacing: 2.w,
                children: [15, 30, 45, 60].map((interval) =>
                  ChoiceChip(
                    label: Text('${interval}min'),
                    selected: _reminderInterval == interval,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _reminderInterval = interval;
                        });
                        _postureReminderTimer?.cancel();
                        _setupPostureReminders();
                        _savePostureData();
                      }
                    },
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reminderAnimationController.dispose();
    _postureReminderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Posture Exercises',
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _configureReminders,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily progress card
            _buildDailyProgressCard(),
            SizedBox(height: 4.h),

            // Posture reminder status
            _buildReminderStatusCard(),
            SizedBox(height: 4.h),

            // Exercise categories
            Text(
              'Exercise Categories',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            
            ..._exerciseCategories.map((category) => 
              _buildCategoryCard(category)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgressCard() {
    final progress = _dailyExercisesCompleted / _dailyExerciseGoal;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.amber.shade300],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                'Daily Progress',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.emoji_events, color: Colors.white),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '$_dailyExercisesCompleted / $_dailyExerciseGoal exercises',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withAlpha(77),
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
          SizedBox(height: 1.h),
          Text(
            progress >= 1.0
              ? 'Daily goal achieved! 🎉'
              : 'Keep going! You\'re doing great.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.white.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderStatusCard() {
    return AnimatedBuilder(
      animation: _reminderAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _reminderAnimation.value,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _postureRemindersEnabled ? Colors.green : Colors.grey,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _postureRemindersEnabled 
                    ? Icons.notifications_active 
                    : Icons.notifications_off,
                  color: _postureRemindersEnabled ? Colors.green : Colors.grey,
                  size: 32,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _postureRemindersEnabled 
                          ? 'Posture Reminders Active'
                          : 'Posture Reminders Disabled',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _postureRemindersEnabled
                          ? 'Reminding every $_reminderInterval minutes'
                          : 'Tap settings to enable reminders',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: _configureReminders,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: category['color'].withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category['icon'],
            color: category['color'],
            size: 24,
          ),
        ),
        title: Text(
          category['name'],
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          category['description'],
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        children: category['exercises'].map<Widget>((exercise) =>
          ListTile(
            leading: CircleAvatar(
              backgroundColor: category['color'].withAlpha(26),
              child: Text(
                '${exercise['duration']}s',
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  color: category['color'],
                ),
              ),
            ),
            title: Text(
              exercise['name'],
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              exercise['description'],
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            trailing: Icon(Icons.play_arrow, color: category['color']),
            onTap: () => _startExercise(exercise),
          ),
        ).toList(),
      ),
    );
  }
}

// Separate screen for exercise details and execution
class ExerciseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onComplete;

  const ExerciseDetailScreen({
    Key? key,
    required this.exercise,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  
  Timer? _exerciseTimer;
  int _remainingSeconds = 0;
  bool _isActive = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.exercise['duration'];
    
    _timerController = AnimationController(
      duration: Duration(seconds: widget.exercise['duration']),
      vsync: this,
    );
    
    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_timerController);
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
    });
    
    _timerController.forward();
    
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      
      if (_remainingSeconds <= 0) {
        _completeExercise();
      }
    });
  }

  void _pauseExercise() {
    setState(() {
      _isActive = false;
    });
    _timerController.stop();
    _exerciseTimer?.cancel();
  }

  void _completeExercise() {
    _exerciseTimer?.cancel();
    _timerController.stop();
    
    widget.onComplete();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 2.w),
            Text('Exercise Complete!'),
          ],
        ),
        content: Text(
          'Great job completing the ${widget.exercise['name']}! Your posture will thank you.',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to main screen
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    _exerciseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructions = List<String>.from(widget.exercise['instructions']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise['name']),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Timer circle
            Expanded(
              flex: 2,
              child: Center(
                child: SizedBox(
                  width: 60.w,
                  height: 60.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _timerAnimation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _timerAnimation.value,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_remainingSeconds',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            'seconds',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Exercise description
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      widget.exercise['description'],
                      style: GoogleFonts.inter(fontSize: 14.sp),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Benefits: ${widget.exercise['benefits']}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Instructions
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: instructions.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 2.w),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: index == _currentStep 
                              ? Theme.of(context).primaryColor.withAlpha(26)
                              : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: index == _currentStep 
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: index == _currentStep 
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400],
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  instructions[index],
                                  style: GoogleFonts.inter(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isActive ? _pauseExercise : _startExercise,
                  icon: Icon(_isActive ? Icons.pause : Icons.play_arrow),
                  label: Text(_isActive ? 'Pause' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _completeExercise,
                  icon: Icon(Icons.skip_next),
                  label: Text('Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}