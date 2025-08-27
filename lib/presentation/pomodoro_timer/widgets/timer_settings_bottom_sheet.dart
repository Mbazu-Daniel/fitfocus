import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TimerSettingsBottomSheet extends StatefulWidget {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int sessionsUntilLongBreak;
  final bool enableNotifications;
  final bool enableDoNotDisturb;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const TimerSettingsBottomSheet({
    super.key,
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.sessionsUntilLongBreak,
    required this.enableNotifications,
    required this.enableDoNotDisturb,
    required this.onSettingsChanged,
  });

  @override
  State<TimerSettingsBottomSheet> createState() =>
      _TimerSettingsBottomSheetState();
}

class _TimerSettingsBottomSheetState extends State<TimerSettingsBottomSheet> {
  late int _workDuration;
  late int _shortBreakDuration;
  late int _longBreakDuration;
  late int _sessionsUntilLongBreak;
  late bool _enableNotifications;
  late bool _enableDoNotDisturb;
  
  // Preset configurations for different work styles
  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Classic Pomodoro',
      'description': 'Traditional 25-5-15 pattern',
      'work': 25,
      'shortBreak': 5,
      'longBreak': 15,
      'sessions': 4,
    },
    {
      'name': 'Extended Focus',
      'description': 'Longer work sessions for deep work',
      'work': 45,
      'shortBreak': 10,
      'longBreak': 25,
      'sessions': 3,
    },
    {
      'name': 'Quick Sprints',
      'description': 'Short bursts for high energy work',
      'work': 15,
      'shortBreak': 3,
      'longBreak': 10,
      'sessions': 6,
    },
    {
      'name': 'Study Sessions',
      'description': 'Optimized for learning and retention',
      'work': 30,
      'shortBreak': 5,
      'longBreak': 20,
      'sessions': 4,
    },
    {
      'name': 'Meeting Prep',
      'description': 'Perfect for preparation tasks',
      'work': 20,
      'shortBreak': 5,
      'longBreak': 15,
      'sessions': 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _workDuration = widget.workDuration;
    _shortBreakDuration = widget.shortBreakDuration;
    _longBreakDuration = widget.longBreakDuration;
    _sessionsUntilLongBreak = widget.sessionsUntilLongBreak;
    _enableNotifications = widget.enableNotifications;
    _enableDoNotDisturb = widget.enableDoNotDisturb;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 90.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Title
          Text(
            'Timer Settings',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 3.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preset configurations
                  _buildPresetsSection(theme),
                  
                  SizedBox(height: 4.h),
                  
                  // Custom duration settings
                  _buildCustomSettingsSection(theme),
                  
                  SizedBox(height: 4.h),
                  
                  // Notification settings
                  _buildNotificationSettings(theme),
                ],
              ),
            ),
          ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onSettingsChanged({
                      'workDuration': _workDuration,
                      'shortBreakDuration': _shortBreakDuration,
                      'longBreakDuration': _longBreakDuration,
                      'sessionsUntilLongBreak': _sessionsUntilLongBreak,
                      'enableNotifications': _enableNotifications,
                      'enableDoNotDisturb': _enableDoNotDisturb,
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Choose a pre-configured timer setup',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 25.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _presets.length,
            itemBuilder: (context, index) {
              final preset = _presets[index];
              final isSelected = preset['work'] == _workDuration &&
                  preset['shortBreak'] == _shortBreakDuration &&
                  preset['longBreak'] == _longBreakDuration &&
                  preset['sessions'] == _sessionsUntilLongBreak;

              return Container(
                width: 60.w,
                margin: EdgeInsets.only(right: 3.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor.withAlpha(26)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor
                        : Colors.grey.withAlpha(77),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _workDuration = preset['work'];
                      _shortBreakDuration = preset['shortBreak'];
                      _longBreakDuration = preset['longBreak'];
                      _sessionsUntilLongBreak = preset['sessions'];
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                preset['name'],
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? theme.primaryColor
                                      : Colors.black,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          preset['description'],
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        _buildPresetDetails(preset, theme),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPresetDetails(Map<String, dynamic> preset, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Work:',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${preset['work']}min',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Short break:',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${preset['shortBreak']}min',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Long break:',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${preset['longBreak']}min',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sessions:',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${preset['sessions']}',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Settings',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Fine-tune your timer durations',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        
        _buildDurationSetting(
          context: context,
          title: 'Work Duration',
          value: _workDuration,
          onChanged: (value) => setState(() => _workDuration = value),
          min: 5,
          max: 90,
        ),

        _buildDurationSetting(
          context: context,
          title: 'Short Break',
          value: _shortBreakDuration,
          onChanged: (value) => setState(() => _shortBreakDuration = value),
          min: 2,
          max: 20,
        ),

        _buildDurationSetting(
          context: context,
          title: 'Long Break',
          value: _longBreakDuration,
          onChanged: (value) => setState(() => _longBreakDuration = value),
          min: 10,
          max: 45,
        ),

        _buildDurationSetting(
          context: context,
          title: 'Sessions Until Long Break',
          value: _sessionsUntilLongBreak,
          onChanged: (value) =>
              setState(() => _sessionsUntilLongBreak = value),
          min: 2,
          max: 10,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Manage alert preferences',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        
        _buildToggleSetting(
          context: context,
          title: 'Enable Notifications',
          subtitle: 'Get notified when sessions end',
          value: _enableNotifications,
          onChanged: (value) => setState(() => _enableNotifications = value),
        ),

        _buildToggleSetting(
          context: context,
          title: 'Do Not Disturb',
          subtitle: 'Silence notifications during work sessions',
          value: _enableDoNotDisturb,
          onChanged: (value) => setState(() => _enableDoNotDisturb = value),
        ),
      ],
    );
  }
  }

  Widget _buildDurationSetting({
    required BuildContext context,
    required String title,
    required int value,
    required Function(int) onChanged,
    required int min,
    required int max,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                '${min}min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: max - min,
                  onChanged: (newValue) {
                    HapticFeedback.selectionClick();
                    onChanged(newValue.round());
                  },
                ),
              ),
              Text(
                '${max}min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value}min',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}
