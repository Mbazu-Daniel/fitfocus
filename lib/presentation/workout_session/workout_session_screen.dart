import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  
  Timer? _workoutTimer;
  Duration _sessionDuration = Duration.zero;
  bool _isActive = false;
  int _currentExercise = 0;
  int _currentSet = 1;
  int _currentRep = 0;
  
  // Sample workout data
  final List<Map<String, dynamic>> _exercises = [
    {
      'name': 'Desk Push-ups',
      'sets': 3,
      'reps': 10,
      'description': 'Push against your desk to strengthen chest and arms',
      'duration': 30,
    },
    {
      'name': 'Chair Dips',
      'sets': 3,
      'reps': 8,
      'description': 'Use your chair to work triceps and shoulders',
      'duration': 25,
    },
    {
      'name': 'Seated Leg Extensions',
      'sets': 2,
      'reps': 15,
      'description': 'Strengthen your quadriceps while seated',
      'duration': 20,
    },
    {
      'name': 'Neck Stretches',
      'sets': 1,
      'reps': 5,
      'description': 'Gentle neck movements to relieve tension',
      'duration': 60,
    },
    {
      'name': 'Shoulder Rolls',
      'sets': 2,
      'reps': 10,
      'description': 'Roll shoulders to improve posture',
      'duration': 30,
    },
  ];

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(minutes: 1),
      vsync: this,
    );
  }

  void _startWorkout() {
    setState(() {
      _isActive = true;
    });
    
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _sessionDuration += const Duration(seconds: 1);
      });
    });
  }

  void _pauseWorkout() {
    setState(() {
      _isActive = false;
    });
    _workoutTimer?.cancel();
  }

  void _completeSet() {
    final currentExercise = _exercises[_currentExercise];
    
    if (_currentSet < currentExercise['sets']) {
      setState(() {
        _currentSet++;
        _currentRep = 0;
      });
    } else {
      _nextExercise();
    }
  }

  void _nextExercise() {
    if (_currentExercise < _exercises.length - 1) {
      setState(() {
        _currentExercise++;
        _currentSet = 1;
        _currentRep = 0;
      });
    } else {
      _completeWorkout();
    }
  }

  void _completeWorkout() {
    _workoutTimer?.cancel();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            SizedBox(width: 2.w),
            Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            SizedBox(height: 2.h),
            Text(
              'Congratulations! You completed your workout in ${_formatDuration(_sessionDuration)}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to dashboard
            },
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timerController.dispose();
    _workoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _exercises[_currentExercise];
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Workout Session',
        actions: [
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: _isActive ? _pauseWorkout : null,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Session timer
            _buildSessionTimer(),
            SizedBox(height: 4.h),
            
            // Current exercise info
            _buildCurrentExercise(currentExercise),
            SizedBox(height: 4.h),
            
            // Progress indicator
            _buildProgressIndicator(),
            SizedBox(height: 4.h),
            
            // Control buttons
            _buildControlButtons(),
            
            Spacer(),
            
            // Exercise list
            _buildExerciseList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTimer() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(204),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Time',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.white.withAlpha(204),
                ),
              ),
              Text(
                _formatDuration(_sessionDuration),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Icon(
            _isActive ? Icons.play_circle : Icons.pause_circle,
            color: Colors.white,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise(Map<String, dynamic> exercise) {
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
            exercise['name'],
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            exercise['description'],
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildExerciseMetric('Set', '$_currentSet/${exercise['sets']}'),
              _buildExerciseMetric('Reps', '${exercise['reps']}'),
              _buildExerciseMetric('Duration', '${exercise['duration']}s'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentExercise + 1) / _exercises.length;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_currentExercise + 1}/${_exercises.length}',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        if (!_isActive)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _startWorkout,
              icon: Icon(Icons.play_arrow),
              label: Text('Start Workout'),
            ),
          ),
        if (_isActive) ..[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _completeSet,
              icon: Icon(Icons.check),
              label: Text('Complete Set'),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _nextExercise,
              icon: Icon(Icons.skip_next),
              label: Text('Skip Exercise'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExerciseList() {
    return Container(
      height: 30.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\\'s Exercises',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                final isCompleted = index < _currentExercise;
                final isCurrent = index == _currentExercise;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 2.w),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Theme.of(context).primaryColor.withAlpha(26)
                        : isCompleted
                            ? Colors.green.withAlpha(26)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? Theme.of(context).primaryColor
                          : isCompleted
                              ? Colors.green
                              : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : isCurrent
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : isCurrent
                                  ? Icons.play_arrow
                                  : Icons.fitness_center,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise['name'],
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? Colors.green : null,
                              ),
                            ),
                            Text(
                              '${exercise['sets']} sets × ${exercise['reps']} reps',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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
    );
  }
}