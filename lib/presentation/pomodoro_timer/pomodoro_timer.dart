import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/break_suggestions_widget.dart';
import './widgets/session_counter_widget.dart';
import './widgets/timer_controls_widget.dart';
import './widgets/timer_display_widget.dart';
import './widgets/timer_settings_bottom_sheet.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with TickerProviderStateMixin {
  // Timer state
  Timer? _timer;
  Duration _remainingTime = Duration(minutes: 25);
  Duration _totalTime = Duration(minutes: 25);
  bool _isActive = false;
  bool _isPaused = false;
  String _sessionType = 'Work';
  int _currentSession = 1;
  int _completedSessions = 0;

  // Settings
  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _totalSessions = 4;
  int _sessionsUntilLongBreak = 4;
  bool _enableNotifications = true;
  bool _enableDoNotDisturb = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _celebrationController;

  // Mock break suggestions data
  final List<Map<String, dynamic>> _breakSuggestions = [
    {
      "id": 1,
      "name": "Desk Stretches",
      "duration": "2-3 minutes",
      "difficulty": "Easy",
      "icon": "accessibility_new",
      "description":
          "Simple stretches you can do at your desk to relieve tension",
    },
    {
      "id": 2,
      "name": "Eye Exercises",
      "duration": "1-2 minutes",
      "difficulty": "Easy",
      "icon": "visibility",
      "description": "Reduce eye strain with these quick exercises",
    },
    {
      "id": 3,
      "name": "Quick Walk",
      "duration": "3-5 minutes",
      "difficulty": "Easy",
      "icon": "directions_walk",
      "description": "Take a short walk to refresh your mind and body",
    },
    {
      "id": 4,
      "name": "Deep Breathing",
      "duration": "2-3 minutes",
      "difficulty": "Easy",
      "icon": "air",
      "description": "Mindful breathing exercises to reduce stress",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _resetTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _resetTimer() {
    final duration = _sessionType == 'Work'
        ? Duration(minutes: _workDuration)
        : _isLongBreak()
            ? Duration(minutes: _longBreakDuration)
            : Duration(minutes: _shortBreakDuration);

    setState(() {
      _remainingTime = duration;
      _totalTime = duration;
      _isActive = false;
      _isPaused = false;
    });
  }

  bool _isLongBreak() {
    return _completedSessions > 0 &&
        _completedSessions % _sessionsUntilLongBreak == 0;
  }

  void _startPauseTimer() {
    if (_isActive && !_isPaused) {
      // Pause timer
      _timer?.cancel();
      _pulseController.stop();
      setState(() {
        _isPaused = true;
      });

      if (_enableNotifications) {
        Fluttertoast.showToast(
          msg: "Timer paused",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      // Start or resume timer
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isActive = true;
      _isPaused = false;
    });

    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      } else {
        _completeSession();
      }
    });

    if (_enableNotifications) {
      Fluttertoast.showToast(
        msg: "${_sessionType} session started",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _stopTimer() {
    _showStopConfirmation();
  }

  void _showStopConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Stop Timer?'),
          content: Text('Are you sure you want to stop the current session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _forceStopTimer();
              },
              child: Text(
                'Stop',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _forceStopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _resetTimer();

    if (_enableNotifications) {
      Fluttertoast.showToast(
        msg: "Timer stopped",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _skipSession() {
    _showSkipConfirmation();
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Skip Session?'),
          content: Text(
              'Are you sure you want to skip the current ${_sessionType.toLowerCase()} session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeSession();
              },
              child: Text(
                'Skip',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _completeSession() {
    _timer?.cancel();
    _pulseController.stop();

    // Trigger celebration animation
    _celebrationController.forward().then((_) {
      _celebrationController.reset();
    });

    // Haptic feedback for completion
    HapticFeedback.heavyImpact();

    if (_sessionType == 'Work') {
      _completedSessions++;
      _currentSession++;

      // Switch to break
      setState(() {
        _sessionType = _isLongBreak() ? 'Long Break' : 'Short Break';
      });

      if (_enableNotifications) {
        Fluttertoast.showToast(
          msg:
              "Work session completed! Time for a ${_isLongBreak() ? 'long' : 'short'} break.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
    } else {
      // Switch back to work
      setState(() {
        _sessionType = 'Work';
      });

      if (_enableNotifications) {
        Fluttertoast.showToast(
          msg: "Break completed! Ready for work?",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
    }

    _resetTimer();

    // Auto-start next session after a brief pause
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && !_isActive) {
        _startTimer();
      }
    });
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimerSettingsBottomSheet(
        workDuration: _workDuration,
        shortBreakDuration: _shortBreakDuration,
        longBreakDuration: _longBreakDuration,
        sessionsUntilLongBreak: _sessionsUntilLongBreak,
        enableNotifications: _enableNotifications,
        enableDoNotDisturb: _enableDoNotDisturb,
        onSettingsChanged: (settings) {
          setState(() {
            _workDuration = settings['workDuration'];
            _shortBreakDuration = settings['shortBreakDuration'];
            _longBreakDuration = settings['longBreakDuration'];
            _sessionsUntilLongBreak = settings['sessionsUntilLongBreak'];
            _enableNotifications = settings['enableNotifications'];
            _enableDoNotDisturb = settings['enableDoNotDisturb'];
          });

          // Reset timer with new settings if not active
          if (!_isActive) {
            _resetTimer();
          }

          Fluttertoast.showToast(
            msg: "Settings updated",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
      ),
    );
  }

  void _handleSuggestionTap(Map<String, dynamic> suggestion) {
    Navigator.pushNamed(context, '/exercise-detail');

    Fluttertoast.showToast(
      msg: "Starting ${suggestion['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Color _getBackgroundColor() {
    final theme = Theme.of(context);

    switch (_sessionType) {
      case 'Work':
        return theme.colorScheme.primary.withValues(alpha: 0.05);
      case 'Short Break':
      case 'Long Break':
        return AppTheme.successLight.withValues(alpha: 0.05);
      default:
        return theme.colorScheme.surface;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text('FitFocus Timer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () {
            if (_isActive) {
              _showExitConfirmation();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'history',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/progress-tracking');
            },
            tooltip: 'View Progress',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              SizedBox(height: 2.h),

              // Session counter
              SessionCounterWidget(
                currentSession: _currentSession,
                totalSessions: _totalSessions,
              ),

              SizedBox(height: 4.h),

              // Timer display with pulse animation
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isActive && !_isPaused
                        ? 1.0 + (_pulseController.value * 0.02)
                        : 1.0,
                    child: TimerDisplayWidget(
                      remainingTime: _remainingTime,
                      totalTime: _totalTime,
                      isActive: _isActive,
                      sessionType: _sessionType,
                    ),
                  );
                },
              ),

              SizedBox(height: 6.h),

              // Timer controls
              TimerControlsWidget(
                isActive: _isActive,
                isPaused: _isPaused,
                onStartPause: _startPauseTimer,
                onStop: _stopTimer,
                onSkip: _skipSession,
                onSettings: _showSettings,
              ),

              SizedBox(height: 4.h),

              // Break suggestions (only show during breaks)
              if (_sessionType != 'Work' && !_isActive)
                BreakSuggestionsWidget(
                  suggestions: _breakSuggestions,
                  onSuggestionTap: _handleSuggestionTap,
                ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Exit Timer?'),
          content: Text(
              'You have an active timer running. Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: Text(
                'Exit',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
