import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './widgets/back_button_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';
import './widgets/permission_request_widget.dart';
import './widgets/skip_button_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  bool _showPermissionSheet = false;
  int _currentPermissionIndex = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Boost Your Productivity",
      "description":
          "Master the Pomodoro technique with customizable work and break intervals. Stay focused and accomplish more in less time.",
      "image":
          "https://images.unsplash.com/photo-1611224923853-80b023f02d71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cG9tb2Rvcm98ZW58MHx8MHx8fDA%3D",
    },
    {
      "title": "Break the Sedentary Cycle",
      "description":
          "Combat desk job health risks with targeted exercises designed for office workers. Transform your breaks into wellness moments.",
      "image":
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8b2ZmaWNlJTIwZXhlcmNpc2V8ZW58MHx8MHx8fDA%3D",
    },
    {
      "title": "Join the Community",
      "description":
          "Connect with like-minded professionals, join challenges, and stay motivated with social features and achievement tracking.",
      "image":
          "https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    },
  ];

  final List<Map<String, dynamic>> _permissionData = [
    {
      "title": "Health Permissions",
      "description":
          "Allow access to health data to track your activity and provide personalized exercise recommendations for better wellness.",
      "icon": "favorite",
    },
    {
      "title": "Notification Permissions",
      "description":
          "Enable notifications to receive break reminders, streak updates, and motivational messages to maintain your healthy routine.",
      "icon": "notifications",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showPermissions();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/pomodoro-timer');
  }

  void _showPermissions() {
    setState(() {
      _showPermissionSheet = true;
      _currentPermissionIndex = 0;
    });
    _showPermissionBottomSheet();
  }

  void _showPermissionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PermissionRequestWidget(
        title: (_permissionData[_currentPermissionIndex]["title"] as String),
        description:
            (_permissionData[_currentPermissionIndex]["description"] as String),
        iconName: (_permissionData[_currentPermissionIndex]["icon"] as String),
        onAllow: _handlePermissionAllow,
        onSkip: _handlePermissionSkip,
      ),
    );
  }

  void _handlePermissionAllow() {
    Navigator.pop(context);
    _nextPermission();
  }

  void _handlePermissionSkip() {
    Navigator.pop(context);
    _nextPermission();
  }

  void _nextPermission() {
    if (_currentPermissionIndex < _permissionData.length - 1) {
      setState(() {
        _currentPermissionIndex++;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        _showPermissionBottomSheet();
      });
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, '/pomodoro-timer');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                HapticFeedback.selectionClick();
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingPageWidget(
                  title: data["title"] as String,
                  description: data["description"] as String,
                  imageUrl: data["image"] as String,
                  isLastPage: index == _onboardingData.length - 1,
                  onNext: _nextPage,
                  onGetStarted: _showPermissions,
                );
              },
            ),
            SkipButtonWidget(onSkip: _skipOnboarding),
            BackButtonWidget(
              onBack: _previousPage,
              isVisible: _currentPage > 0,
            ),
            Positioned(
              bottom: 6.h,
              left: 0,
              right: 0,
              child: PageIndicatorWidget(
                currentPage: _currentPage,
                totalPages: _onboardingData.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
