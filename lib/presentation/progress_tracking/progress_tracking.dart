import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievement_badge_widget.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/progress_chart_widget.dart';
import './widgets/streak_calendar_widget.dart';
import './widgets/summary_card_widget.dart';

class ProgressTracking extends StatefulWidget {
  const ProgressTracking({super.key});

  @override
  State<ProgressTracking> createState() => _ProgressTrackingState();
}

class _ProgressTrackingState extends State<ProgressTracking>
    with TickerProviderStateMixin {
  int _selectedDateRange = 1; // 0: Today, 1: Week, 2: Month, 3: Year
  int _selectedTab = 0; // 0: Progress, 1: Exercise, 2: Focus
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Mock data for progress tracking
  final List<Map<String, dynamic>> _pomodoroData = [
    {"label": "Mon", "value": 8, "date": "2025-08-18"},
    {"label": "Tue", "value": 12, "date": "2025-08-19"},
    {"label": "Wed", "value": 6, "date": "2025-08-20"},
    {"label": "Thu", "value": 15, "date": "2025-08-21"},
    {"label": "Fri", "value": 10, "date": "2025-08-22"},
    {"label": "Sat", "value": 4, "date": "2025-08-23"},
    {"label": "Sun", "value": 7, "date": "2025-08-24"},
  ];

  final List<Map<String, dynamic>> _exerciseData = [
    {"label": "Stretching", "value": 45, "percentage": 35},
    {"label": "Walking", "value": 30, "percentage": 25},
    {"label": "Desk Exercises", "value": 25, "percentage": 20},
    {"label": "Yoga", "value": 20, "percentage": 15},
    {"label": "Other", "value": 8, "percentage": 5},
  ];

  final List<Map<String, dynamic>> _focusData = [
    {"label": "9 AM", "value": 85},
    {"label": "11 AM", "value": 92},
    {"label": "1 PM", "value": 78},
    {"label": "3 PM", "value": 88},
    {"label": "5 PM", "value": 75},
  ];

  final List<Map<String, dynamic>> _streakData = [
    {"date": "2025-08-15", "sessions": 3},
    {"date": "2025-08-16", "sessions": 2},
    {"date": "2025-08-17", "sessions": 4},
    {"date": "2025-08-18", "sessions": 2},
    {"date": "2025-08-19", "sessions": 5},
    {"date": "2025-08-20", "sessions": 1},
    {"date": "2025-08-21", "sessions": 3},
  ];

  final List<Map<String, dynamic>> _achievements = [
    {
      "title": "First Week",
      "description": "Complete 7 days of sessions",
      "icon": "calendar_today",
      "isUnlocked": true,
      "unlockedDate": DateTime(2025, 8, 15),
      "progress": 7,
      "target": 7,
    },
    {
      "title": "Focus Master",
      "description": "Complete 25 Pomodoro sessions",
      "icon": "psychology",
      "isUnlocked": false,
      "progress": 18,
      "target": 25,
    },
    {
      "title": "Exercise Enthusiast",
      "description": "Log 100 minutes of exercise",
      "icon": "fitness_center",
      "isUnlocked": true,
      "unlockedDate": DateTime(2025, 8, 20),
      "progress": 128,
      "target": 100,
    },
    {
      "title": "Streak Champion",
      "description": "Maintain a 14-day streak",
      "icon": "local_fire_department",
      "isUnlocked": false,
      "progress": 7,
      "target": 14,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Progress Tracking',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _handleShareProgress,
            tooltip: 'Share Progress',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'file_download',
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _handleExportData,
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  _buildDateRangeSelector(),
                  SizedBox(height: 2.h),
                  _buildMetricCards(),
                  SizedBox(height: 2.h),
                  _buildTabBar(),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProgressTab(),
                  _buildExerciseTab(),
                  _buildFocusTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return DateRangeSelectorWidget(
      options: const ['Today', 'Week', 'Month', 'Year'],
      selectedIndex: _selectedDateRange,
      onSelectionChanged: (index) {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedDateRange = index;
        });
        _updateDataForDateRange(index);
      },
    );
  }

  Widget _buildMetricCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MetricCardWidget(
                title: 'Pomodoros',
                value: '62',
                subtitle: 'This week',
                iconName: 'timer',
                showTrend: true,
                trendValue: 12.5,
                isPositiveTrend: true,
              ),
              MetricCardWidget(
                title: 'Exercise',
                value: '128',
                subtitle: 'Minutes',
                iconName: 'fitness_center',
                showTrend: true,
                trendValue: 8.3,
                isPositiveTrend: true,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MetricCardWidget(
                title: 'Streak',
                value: '7',
                subtitle: 'Days',
                iconName: 'local_fire_department',
                cardColor: AppTheme.successLight.withValues(alpha: 0.1),
              ),
              MetricCardWidget(
                title: 'Productivity',
                value: '85%',
                subtitle: 'Score',
                iconName: 'trending_up',
                showTrend: true,
                trendValue: 5.2,
                isPositiveTrend: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Progress'),
          Tab(text: 'Exercise'),
          Tab(text: 'Focus'),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 2.h, bottom: 4.h),
      child: Column(
        children: [
          ProgressChartWidget(
            title: 'Daily Sessions',
            chartType: 'bar',
            data: _pomodoroData,
            onTap: _handleChartTap,
          ),
          StreakCalendarWidget(
            title: 'Activity Calendar',
            streakData: _streakData,
            currentDate: DateTime.now(),
          ),
          _buildAchievementsSection(),
          _buildSummarySection(),
        ],
      ),
    );
  }

  Widget _buildExerciseTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 2.h, bottom: 4.h),
      child: Column(
        children: [
          ProgressChartWidget(
            title: 'Exercise Distribution',
            chartType: 'pie',
            data: _exerciseData,
            onTap: _handleChartTap,
          ),
          ProgressChartWidget(
            title: 'Weekly Exercise Minutes',
            chartType: 'bar',
            data: [
              {"label": "Mon", "value": 25},
              {"label": "Tue", "value": 30},
              {"label": "Wed", "value": 15},
              {"label": "Thu", "value": 35},
              {"label": "Fri", "value": 20},
              {"label": "Sat", "value": 10},
              {"label": "Sun", "value": 18},
            ],
          ),
          _buildExerciseInsights(),
        ],
      ),
    );
  }

  Widget _buildFocusTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 2.h, bottom: 4.h),
      child: Column(
        children: [
          ProgressChartWidget(
            title: 'Focus Score by Time',
            chartType: 'line',
            data: _focusData,
            onTap: _handleChartTap,
          ),
          ProgressChartWidget(
            title: 'Break Activity Patterns',
            chartType: 'bar',
            data: [
              {"label": "Stretch", "value": 12},
              {"label": "Walk", "value": 8},
              {"label": "Hydrate", "value": 15},
              {"label": "Rest", "value": 5},
              {"label": "Snack", "value": 3},
            ],
          ),
          _buildFocusInsights(),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: _handleViewAllAchievements,
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 25.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _achievements.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return AchievementBadgeWidget(
                  title: achievement['title'] as String,
                  description: achievement['description'] as String,
                  iconName: achievement['icon'] as String,
                  isUnlocked: achievement['isUnlocked'] as bool,
                  unlockedDate: achievement['unlockedDate'] as DateTime?,
                  progress: achievement['progress'] as int,
                  target: achievement['target'] as int,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return SummaryCardWidget(
      title: 'Weekly Summary',
      period: 'Aug 18 - Aug 24, 2025',
      highlights: [
        {
          "icon": "trending_up",
          "title": "Productivity Increased",
          "description": "12% improvement from last week",
          "value": "+12%",
        },
        {
          "icon": "timer",
          "title": "Consistent Sessions",
          "description": "Completed sessions every day",
          "value": "7/7",
        },
        {
          "icon": "fitness_center",
          "title": "Exercise Goal Met",
          "description": "Exceeded weekly target",
          "value": "128min",
        },
      ],
      improvements: [
        {
          "icon": "schedule",
          "title": "Morning Sessions",
          "suggestion": "Try starting earlier for better focus",
        },
        {
          "icon": "self_improvement",
          "title": "Break Activities",
          "suggestion": "Add more variety to your breaks",
        },
      ],
      onViewDetails: _handleViewWeeklyDetails,
    );
  }

  Widget _buildExerciseInsights() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercise Insights',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildInsightItem(
            context,
            'Most Active Day',
            'Thursday',
            '35 minutes',
            'calendar_today',
            AppTheme.successLight,
          ),
          _buildInsightItem(
            context,
            'Favorite Activity',
            'Stretching',
            '45 minutes total',
            'self_improvement',
            AppTheme.accentLight,
          ),
          _buildInsightItem(
            context,
            'Best Time',
            '11:00 AM',
            'Peak activity period',
            'schedule',
            AppTheme.warningLight,
          ),
        ],
      ),
    );
  }

  Widget _buildFocusInsights() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Focus Insights',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildInsightItem(
            context,
            'Peak Focus Time',
            '11:00 AM',
            '92% average score',
            'psychology',
            AppTheme.successLight,
          ),
          _buildInsightItem(
            context,
            'Most Productive Day',
            'Thursday',
            '15 sessions completed',
            'trending_up',
            AppTheme.accentLight,
          ),
          _buildInsightItem(
            context,
            'Break Preference',
            'Hydration',
            'Most frequent break activity',
            'local_drink',
            AppTheme.warningLight,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String title,
    String value,
    String description,
    String iconName,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateDataForDateRange(int index) {
    // Update data based on selected date range
    // This would typically fetch new data from an API
    setState(() {
      // Mock data update logic here
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    HapticFeedback.lightImpact();
  }

  void _handleShareProgress() {
    HapticFeedback.lightImpact();
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Progress shared successfully!'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleExportData() {
    HapticFeedback.lightImpact();
    // Implement data export functionality
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildExportBottomSheet(),
    );
  }

  Widget _buildExportBottomSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Export Data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          _buildExportOption(
              'PDF Report', 'picture_as_pdf', () => _exportAsPDF()),
          _buildExportOption('CSV Data', 'table_chart', () => _exportAsCSV()),
          _buildExportOption('Share Image', 'image', () => _shareAsImage()),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildExportOption(String title, String iconName, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _exportAsPDF() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('PDF report generated successfully!'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _exportAsCSV() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('CSV data exported successfully!'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareAsImage() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Progress image shared successfully!'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleChartTap() {
    HapticFeedback.lightImpact();
    // Implement chart interaction
  }

  void _handleViewAllAchievements() {
    HapticFeedback.lightImpact();
    // Navigate to achievements screen
  }

  void _handleViewWeeklyDetails() {
    HapticFeedback.lightImpact();
    // Navigate to detailed weekly report
  }
}
