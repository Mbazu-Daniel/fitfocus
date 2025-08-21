import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _progressAnimation;

  bool _isInitializing = true;
  double _initializationProgress = 0.0;
  String _currentTask = 'Initializing FitFocus...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo scale animation with bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  Future<void> _startInitialization() async {
    // Start progress animation
    _progressAnimationController.forward();

    // Simulate initialization tasks with realistic timing
    await _performInitializationTasks();

    // Navigate to appropriate screen after initialization
    if (mounted) {
      _navigateToNextScreen();
    }
  }

  Future<void> _performInitializationTasks() async {
    final tasks = [
      {'task': 'Loading user preferences...', 'duration': 400},
      {'task': 'Checking authentication...', 'duration': 600},
      {'task': 'Syncing health data...', 'duration': 500},
      {'task': 'Preparing exercise library...', 'duration': 450},
      {'task': 'Setting up notifications...', 'duration': 350},
      {'task': 'Finalizing setup...', 'duration': 300},
    ];

    for (int i = 0; i < tasks.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentTask = tasks[i]['task'] as String;
        _initializationProgress = (i + 1) / tasks.length;
      });

      await Future.delayed(Duration(milliseconds: tasks[i]['duration'] as int));
    }

    // Final delay to show completion
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _navigateToNextScreen() {
    // Simulate authentication check and navigation logic
    // In a real app, this would check actual user state
    final isFirstTime = true; // Mock check for first-time user
    final isAuthenticated = false; // Mock authentication status

    String targetRoute;
    if (isFirstTime) {
      targetRoute = '/onboarding-flow';
    } else if (isAuthenticated) {
      targetRoute = '/pomodoro-timer'; // Main dashboard
    } else {
      targetRoute = '/onboarding-flow'; // Login screen would be here
    }

    // Smooth transition to next screen
    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildGradientBackground(),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildLogoSection(),
                ),
                Expanded(
                  flex: 1,
                  child: _buildProgressSection(),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryLight,
          AppTheme.primaryVariantLight,
          AppTheme.secondaryLight.withValues(alpha: 0.8),
        ],
        stops: const [0.0, 0.6, 1.0],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: AnimatedBuilder(
        animation: _logoAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _logoOpacityAnimation.value,
            child: Transform.scale(
              scale: _logoScaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAppLogo(),
                  SizedBox(height: 3.h),
                  _buildAppTitle(),
                  SizedBox(height: 1.h),
                  _buildTagline(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Timer icon
          Positioned(
            top: 15,
            left: 15,
            child: CustomIconWidget(
              iconName: 'timer',
              color: Colors.white,
              size: 20,
            ),
          ),
          // Fitness icon
          Positioned(
            bottom: 15,
            right: 15,
            child: CustomIconWidget(
              iconName: 'fitness_center',
              color: Colors.white,
              size: 20,
            ),
          ),
          // Central focus icon
          Center(
            child: CustomIconWidget(
              iconName: 'center_focus_strong',
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTitle() {
    return Text(
      'FitFocus',
      style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Focus • Move • Thrive',
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w400,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressIndicator(),
          SizedBox(height: 2.h),
          _buildProgressText(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value * _initializationProgress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _currentTask,
        key: ValueKey(_currentTask),
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
