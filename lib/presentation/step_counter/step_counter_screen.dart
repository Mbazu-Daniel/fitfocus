import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({Key? key}) : super(key: key);

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen>
    with TickerProviderStateMixin {
  late AnimationController _stepAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _stepAnimation;
  late Animation<double> _progressAnimation;

  int _currentSteps = 0;
  int _dailyGoal = 8000;
  double _caloriesBurned = 0.0;
  double _distanceWalked = 0.0;
  bool _isTracking = false;
  Timer? _simulationTimer;

  // Achievement levels
  final List<Map<String, dynamic>> _achievements = [
    {'steps': 1000, 'name': 'First Steps', 'icon': Icons.directions_walk},
    {'steps': 5000, 'name': 'Daily Walker', 'icon': Icons.local_fire_department},
    {'steps': 8000, 'name': 'Step Master', 'icon': Icons.emoji_events},
    {'steps': 10000, 'name': 'Step Champion', 'icon': Icons.star},
    {'steps': 15000, 'name': 'Step Legend', 'icon': Icons.military_tech},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadStepData();
  }

  void _initializeAnimations() {
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _stepAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadStepData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    
    setState(() {
      _currentSteps = prefs.getInt('steps_$today') ?? 0;
      _dailyGoal = prefs.getInt('daily_goal') ?? 8000;
      _isTracking = prefs.getBool('step_tracking') ?? false;
      _calculateMetrics();
    });

    _progressAnimationController.animateTo(_currentSteps / _dailyGoal);
  }

  Future<void> _saveStepData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    
    await prefs.setInt('steps_$today', _currentSteps);
    await prefs.setInt('daily_goal', _dailyGoal);
    await prefs.setBool('step_tracking', _isTracking);
  }

  void _calculateMetrics() {
    // Approximate calculations
    _caloriesBurned = _currentSteps * 0.04; // ~0.04 calories per step
    _distanceWalked = _currentSteps * 0.0008; // ~0.8 meters per step
  }

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });

    if (_isTracking) {
      _startStepSimulation();
    } else {
      _stopStepSimulation();
    }

    _saveStepData();
  }

  void _startStepSimulation() {
    // Simulate step counting for demo purposes
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isTracking) {
        final random = Random();
        final newSteps = random.nextInt(3) + 1; // 1-3 steps every 2 seconds
        
        setState(() {
          _currentSteps += newSteps;
          _calculateMetrics();
        });

        _stepAnimationController.forward().then((_) {
          _stepAnimationController.reset();
        });

        _progressAnimationController.animateTo(
          (_currentSteps / _dailyGoal).clamp(0.0, 1.0)
        );

        _saveStepData();
      }
    });
  }

  void _stopStepSimulation() {
    _simulationTimer?.cancel();
  }

  void _resetSteps() {
    setState(() {
      _currentSteps = 0;
      _calculateMetrics();
    });
    _progressAnimationController.reset();
    _saveStepData();
  }

  void _setDailyGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Daily Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose your daily step goal:'),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              children: [5000, 8000, 10000, 12000, 15000].map((goal) =>
                ChoiceChip(
                  label: Text('${goal}'),
                  selected: _dailyGoal == goal,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _dailyGoal = goal;
                      });
                      _progressAnimationController.animateTo(
                        (_currentSteps / _dailyGoal).clamp(0.0, 1.0)
                      );
                      _saveStepData();
                      Navigator.pop(context);
                    }
                  },
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getEarnedAchievements() {
    return _achievements.where((achievement) => 
      _currentSteps >= achievement['steps']
    ).toList();
  }

  @override
  void dispose() {
    _stepAnimationController.dispose();
    _progressAnimationController.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentSteps / _dailyGoal).clamp(0.0, 1.0);
    final earnedAchievements = _getEarnedAchievements();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Step Counter',
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _setDailyGoal,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetSteps,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Main step counter widget
            _buildStepCounterWidget(progress),
            SizedBox(height: 4.h),

            // Tracking toggle
            _buildTrackingToggle(),
            SizedBox(height: 4.h),

            // Metrics cards
            _buildMetricsCards(),
            SizedBox(height: 4.h),

            // Achievements
            if (earnedAchievements.isNotEmpty) ...[
              _buildAchievementsSection(earnedAchievements),
              SizedBox(height: 4.h),
            ],

            // Progress history
            _buildProgressHistory(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4, // Steps tab
        onTap: (index) => CustomBottomBar.handleNavigation(context, index),
      ),
    );
  }

  Widget _buildStepCounterWidget(double progress) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(204),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress circle
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 60.w,
                  height: 60.w,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withAlpha(77),
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withAlpha(51),
                    ),
                  ),
                ),
                // Progress circle
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 60.w,
                      height: 60.w,
                      child: CircularProgressIndicator(
                        value: _progressAnimation.value * progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    );
                  },
                ),
                // Step count
                AnimatedBuilder(
                  animation: _stepAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_stepAnimation.value * 0.1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_currentSteps',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'STEPS',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(204),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // Goal progress text
          Text(
            '${(_currentSteps / _dailyGoal * 100).toStringAsFixed(1)}% of daily goal',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Text(
            'Goal: $_dailyGoal steps',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.white.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isTracking ? Icons.pause_circle : Icons.play_circle,
            color: _isTracking ? Colors.red : Colors.green,
            size: 32,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isTracking ? 'Step Tracking Active' : 'Step Tracking Paused',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isTracking 
                    ? 'Counting your steps automatically'
                    : 'Tap to start tracking your steps',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isTracking,
            onChanged: (value) => _toggleTracking(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Calories',
            '${_caloriesBurned.toStringAsFixed(1)}',
            'kcal',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildMetricCard(
            'Distance',
            '${_distanceWalked.toStringAsFixed(2)}',
            'km',
            Icons.straighten,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(List<Map<String, dynamic>> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements Unlocked',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 12.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                margin: EdgeInsets.only(right: 3.w),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      achievement['icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      achievement['name'],
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHistory() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Progress',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Started tracking: ${_isTracking ? 'Active' : 'Paused'}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Updated: ${DateTime.now().toString().substring(11, 16)}',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}