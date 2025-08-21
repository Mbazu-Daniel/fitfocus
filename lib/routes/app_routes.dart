import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/exercise_detail/exercise_detail.dart';
import '../presentation/exercise_library/exercise_library.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/pomodoro_timer/pomodoro_timer.dart';
import '../presentation/progress_tracking/progress_tracking.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/signup_screen.dart';
import '../presentation/auth/forgot_password_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String splashScreen = '/splash-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String exerciseLibrary = '/exercise-library';
  static const String exerciseDetail = '/exercise-detail';
  static const String pomodoroTimer = '/pomodoro-timer';
  static const String progressTracking = '/progress-tracking';

  // New auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // New fitness routes
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String workoutSession = '/workout-session';
  static const String workoutHistory = '/workout-history';
  static const String goals = '/goals';
  static const String nutrition = '/nutrition';

  // Keep existing initial route or change to dashboard
  static const String initial = splashScreen;

  static Map<String, WidgetBuilder> get routes => {
        splashScreen: (context) => const SplashScreen(),
        onboardingFlow: (context) => const OnboardingFlow(),
        exerciseLibrary: (context) => const ExerciseLibrary(),
        exerciseDetail: (context) => const ExerciseDetail(),
        pomodoroTimer: (context) => const PomodoroTimer(),
        progressTracking: (context) => const ProgressTracking(),

        // New auth routes,
        login: (context) => const LoginScreen(),
        signup: (context) => const SignupScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),

        // New fitness routes,
        dashboard: (context) => const DashboardScreen(),
        // Add more routes as you create the screens
      };
}
