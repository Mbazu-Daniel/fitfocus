import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 3.h),

          // Duration settings
          _buildDurationSetting(
            context: context,
            title: 'Work Duration',
            value: _workDuration,
            onChanged: (value) => setState(() => _workDuration = value),
            min: 15,
            max: 60,
          ),

          _buildDurationSetting(
            context: context,
            title: 'Short Break',
            value: _shortBreakDuration,
            onChanged: (value) => setState(() => _shortBreakDuration = value),
            min: 5,
            max: 15,
          ),

          _buildDurationSetting(
            context: context,
            title: 'Long Break',
            value: _longBreakDuration,
            onChanged: (value) => setState(() => _longBreakDuration = value),
            min: 15,
            max: 30,
          ),

          _buildDurationSetting(
            context: context,
            title: 'Sessions Until Long Break',
            value: _sessionsUntilLongBreak,
            onChanged: (value) =>
                setState(() => _sessionsUntilLongBreak = value),
            min: 2,
            max: 8,
          ),

          SizedBox(height: 2.h),

          // Toggle settings
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

          SizedBox(height: 4.h),

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
                  child: Text('Save'),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
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
