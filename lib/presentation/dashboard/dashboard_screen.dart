import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/fitness_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic> _userStats = {};
  List<Map<String, dynamic>> _recentSessions = [];
  List<Map<String, dynamic>> _activeGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        FitnessService.instance.getUserProfile(),
        FitnessService.instance.getUserStats(),
        FitnessService.instance.getUserWorkoutSessions(limit: 3),
        FitnessService.instance.getUserGoals(),
      ]);

      setState(() {
        _userProfile = results[0] as Map<String, dynamic>?;
        _userStats = results[1] as Map<String, dynamic>;
        _recentSessions = List<Map<String, dynamic>>.from(results[2] as List);
        _activeGoals = (results[3] as List<Map<String, dynamic>>)
            .where((goal) => !goal['is_achieved'])
            .take(2)
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      debugPrint('Dashboard error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(),

              SizedBox(height: 4.h),

              // Stats overview
              _buildStatsOverview(),

              SizedBox(height: 4.h),

              // Quick actions
              _buildQuickActions(),

              SizedBox(height: 4.h),

              // Goals progress
              if (_activeGoals.isNotEmpty) ...[
                _buildGoalsSection(),
                SizedBox(height: 4.h),
              ],

              // Recent activity
              _buildRecentActivitySection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) => CustomBottomBar.handleNavigation(context, index),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final userName =
        _userProfile?['full_name']?.toString().split(' ')[0] ?? 'User';

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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName! 👋',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Ready for your workout today?',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withAlpha(51),
            backgroundImage: _userProfile?['profile_image_url'] != null
                ? CachedNetworkImageProvider(_userProfile!['profile_image_url'])
                : null,
            child: _userProfile?['profile_image_url'] == null
                ? Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Workouts',
                _userStats['completed_workouts']?.toString() ?? '0',
                Icons.fitness_center,
                Colors.blue,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildStatCard(
                'Sets Completed',
                _userStats['total_sets_completed']?.toString() ?? '0',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Current Weight',
                _userStats['current_weight'] != null
                    ? '${_userStats['current_weight']} kg'
                    : 'N/A',
                Icons.scale,
                Colors.orange,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildStatCard(
                'Active Days',
                '${DateTime.now().difference(DateTime.parse(_userProfile?['created_at'] ?? DateTime.now().toIso8601String())).inDays}',
                Icons.calendar_today,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 1.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Smart Planner',
                Icons.psychology,
                Colors.purple,
                () => Navigator.pushNamed(context, AppRoutes.workoutPlanner),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                'Start Workout',
                Icons.play_arrow,
                Colors.green,
                () => Navigator.pushNamed(context, AppRoutes.workoutSession),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
            Expanded(
              child: _buildActionButton(
                'Browse Exercises',
                Icons.search,
                Colors.blue,
                () => Navigator.pushNamed(context, AppRoutes.exerciseBrowser),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Track Progress',
                Icons.trending_up,
                Colors.orange,
                () => Navigator.pushNamed(context, AppRoutes.progressTracking),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                'Log Nutrition',
                Icons.restaurant,
                Colors.red,
                () => Navigator.pushNamed(context, AppRoutes.nutrition),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 1.h),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Goals',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.goals),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ..._activeGoals.map((goal) => _buildGoalCard(goal)).toList(),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final targetValue = goal['target_value']?.toDouble() ?? 1.0;
    final currentValue = goal['current_value']?.toDouble() ?? 0.0;
    final progress =
        targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal['goal_type']?.toString().replaceAll('_', ' ').toUpperCase() ??
                'GOAL',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
          SizedBox(height: 1.h),
          Text(
            '${currentValue.toStringAsFixed(1)} / ${targetValue.toStringAsFixed(1)} ${goal['target_unit'] ?? ''}',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Workouts',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.workoutHistory),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _recentSessions.isEmpty
            ? Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No workouts yet. Start your first workout!',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            : Column(
                children: _recentSessions
                    .map((session) => _buildWorkoutCard(session))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> session) {
    final workoutName = session['name']?.toString() ?? 'Workout';
    final planName = session['workout_plans']?['name']?.toString();
    final status = session['status']?.toString() ?? 'unknown';
    final duration = session['duration_minutes']?.toString();
    final createdAt = DateTime.parse(session['created_at']);

    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: _getStatusColor(status).withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(status),
              color: _getStatusColor(status),
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutName,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (planName != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    planName,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: 0.5.h),
                Text(
                  '${_formatDate(createdAt)}${duration != null ? ' • ${duration}min' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'planned':
        return Colors.orange;
      case 'skipped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'active':
        return Icons.play_circle;
      case 'planned':
        return Icons.schedule;
      case 'skipped':
        return Icons.cancel;
      default:
        return Icons.fitness_center;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}