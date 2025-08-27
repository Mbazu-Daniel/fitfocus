import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({Key? key}) : super(key: key);

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen>
    with TickerProviderStateMixin {
  late AnimationController _waterAnimationController;
  late AnimationController _dropAnimationController;
  late Animation<double> _waterLevelAnimation;
  late Animation<double> _dropAnimation;

  double _dailyIntake = 0.0; // ml
  double _dailyGoal = 2000.0; // ml (default 2L)
  List<Map<String, dynamic>> _waterLogs = [];
  bool _remindersEnabled = true;
  int _reminderInterval = 60; // minutes
  Timer? _reminderTimer;
  DateTime? _lastReminder;

  // Common water serving sizes (in ml)
  final List<Map<String, dynamic>> _servingSizes = [
    {'name': 'Glass', 'amount': 250, 'icon': Icons.local_drink},
    {'name': 'Bottle', 'amount': 500, 'icon': Icons.sports_bar},
    {'name': 'Large Bottle', 'amount': 750, 'icon': Icons.local_bar},
    {'name': 'Cup', 'amount': 200, 'icon': Icons.coffee},
    {'name': 'Custom', 'amount': 0, 'icon': Icons.edit},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadWaterData();
    _setupReminders();
  }

  void _initializeAnimations() {
    _waterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _dropAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _waterLevelAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _waterAnimationController,
      curve: Curves.easeInOut,
    ));

    _dropAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _dropAnimationController,
      curve: Curves.bounceIn,
    ));
  }

  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    
    setState(() {
      _dailyIntake = prefs.getDouble('water_intake_$today') ?? 0.0;
      _dailyGoal = prefs.getDouble('water_goal') ?? 2000.0;
      _remindersEnabled = prefs.getBool('water_reminders') ?? true;
      _reminderInterval = prefs.getInt('reminder_interval') ?? 60;
      
      // Load today's water logs
      final logsJson = prefs.getStringList('water_logs_$today') ?? [];
      _waterLogs = logsJson.map((log) {
        final parts = log.split('|');
        return {
          'time': parts[0],
          'amount': double.parse(parts[1]),
          'type': parts[2],
        };
      }).toList();
    });

    _waterAnimationController.animateTo(_dailyIntake / _dailyGoal);
  }

  Future<void> _saveWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    
    await prefs.setDouble('water_intake_$today', _dailyIntake);
    await prefs.setDouble('water_goal', _dailyGoal);
    await prefs.setBool('water_reminders', _remindersEnabled);
    await prefs.setInt('reminder_interval', _reminderInterval);
    
    // Save logs
    final logsJson = _waterLogs.map((log) => 
      '${log['time']}|${log['amount']}|${log['type']}'
    ).toList();
    await prefs.setStringList('water_logs_$today', logsJson);
  }

  void _setupReminders() {
    if (_remindersEnabled) {
      _reminderTimer = Timer.periodic(
        Duration(minutes: _reminderInterval),
        (timer) => _showReminderNotification(),
      );
    }
  }

  void _showReminderNotification() {
    final now = DateTime.now();
    
    // Don't remind too frequently or outside reasonable hours
    if (_lastReminder != null &&
        now.difference(_lastReminder!).inMinutes < _reminderInterval) {
      return;
    }
    
    if (now.hour < 7 || now.hour > 22) return; // Quiet hours
    
    _lastReminder = now;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.water_drop, color: Colors.blue),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Time to hydrate! 💧 Drink some water.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Add Water',
            onPressed: () => _showQuickAddDialog(),
          ),
          backgroundColor: Colors.blue.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _addWaterIntake(double amount, String type) {
    setState(() {
      _dailyIntake += amount;
      _waterLogs.insert(0, {
        'time': DateTime.now().toString().substring(11, 16),
        'amount': amount,
        'type': type,
      });
    });

    _dropAnimationController.forward().then((_) {
      _dropAnimationController.reset();
    });

    _waterAnimationController.animateTo(
      (_dailyIntake / _dailyGoal).clamp(0.0, 1.0)
    );

    _saveWaterData();

    // Show celebration for goal achievement
    if (_dailyIntake >= _dailyGoal) {
      _showGoalAchievedDialog();
    }
  }

  void _showQuickAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Water Intake'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _servingSizes.map((serving) => ListTile(
            leading: Icon(serving['icon']),
            title: Text(serving['name']),
            subtitle: serving['amount'] > 0 
              ? Text('${serving['amount']} ml')
              : null,
            onTap: () {
              Navigator.pop(context);
              if (serving['amount'] > 0) {
                _addWaterIntake(serving['amount'].toDouble(), serving['name']);
              } else {
                _showCustomAmountDialog();
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showCustomAmountDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Custom Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (ml)',
                hintText: 'e.g., 300',
                prefixIcon: Icon(Icons.water_drop),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _addWaterIntake(amount, 'Custom');
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showGoalAchievedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 2.w),
            Text('Goal Achieved!'),
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
              'Congratulations! You\'ve reached your daily hydration goal of ${_dailyGoal.toInt()} ml!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _setDailyGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Daily Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose your daily hydration goal:'),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              children: [1500, 2000, 2500, 3000, 3500].map((goal) =>
                ChoiceChip(
                  label: Text('${(goal / 1000).toStringAsFixed(1)}L'),
                  selected: _dailyGoal == goal,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _dailyGoal = goal.toDouble();
                      });
                      _waterAnimationController.animateTo(
                        (_dailyIntake / _dailyGoal).clamp(0.0, 1.0)
                      );
                      _saveWaterData();
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

  void _configureReminders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reminder Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Enable Reminders'),
              value: _remindersEnabled,
              onChanged: (value) {
                setState(() {
                  _remindersEnabled = value;
                });
                if (value) {
                  _setupReminders();
                } else {
                  _reminderTimer?.cancel();
                }
                _saveWaterData();
              },
            ),
            if (_remindersEnabled) ...[
              SizedBox(height: 2.h),
              Text('Remind every:'),
              Wrap(
                spacing: 2.w,
                children: [30, 60, 90, 120].map((interval) =>
                  ChoiceChip(
                    label: Text('${interval}min'),
                    selected: _reminderInterval == interval,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _reminderInterval = interval;
                        });
                        _reminderTimer?.cancel();
                        _setupReminders();
                        _saveWaterData();
                      }
                    },
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _resetDaily() {
    setState(() {
      _dailyIntake = 0.0;
      _waterLogs.clear();
    });
    _waterAnimationController.reset();
    _saveWaterData();
  }

  @override
  void dispose() {
    _waterAnimationController.dispose();
    _dropAnimationController.dispose();
    _reminderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dailyIntake / _dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Water Reminder',
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _configureReminders,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetDaily,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Water level visualization
            _buildWaterLevelWidget(progress),
            SizedBox(height: 4.h),

            // Quick add buttons
            _buildQuickAddButtons(),
            SizedBox(height: 4.h),

            // Daily stats
            _buildDailyStats(),
            SizedBox(height: 4.h),

            // Today's logs
            _buildWaterLogs(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddDialog,
        child: AnimatedBuilder(
          animation: _dropAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_dropAnimation.value * 0.2),
              child: Icon(Icons.add_circle),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWaterLevelWidget(double progress) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.cyan.shade300],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Water bottle visualization
          SizedBox(
            width: 50.w,
            height: 50.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bottle outline
                Container(
                  width: 40.w,
                  height: 45.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // Water level
                AnimatedBuilder(
                  animation: _waterLevelAnimation,
                  builder: (context, child) {
                    return Positioned(
                      bottom: 2.w,
                      child: Container(
                        width: 34.w,
                        height: (39.w * _waterLevelAnimation.value * progress),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(179),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    );
                  },
                ),
                // Intake amount
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_dailyIntake.toInt()}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'ml',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // Progress text
          Text(
            '${(progress * 100).toStringAsFixed(1)}% of daily goal',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Text(
            'Goal: ${(_dailyGoal / 1000).toStringAsFixed(1)}L',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.white.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: _servingSizes.take(4).map((serving) => 
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 2.w),
                child: _buildQuickAddButton(
                  serving['name'],
                  serving['amount'].toString(),
                  serving['icon'],
                  () => _addWaterIntake(
                    serving['amount'].toDouble(),
                    serving['name']
                  ),
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(
    String name,
    String amount,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withAlpha(77)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            SizedBox(height: 1.h),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${amount}ml',
              style: GoogleFonts.inter(
                fontSize: 8.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats() {
    final remaining = (_dailyGoal - _dailyIntake).clamp(0.0, double.infinity);
    final percentage = ((_dailyIntake / _dailyGoal) * 100).clamp(0.0, 100.0);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Remaining',
            '${remaining.toInt()}',
            'ml',
            Icons.schedule,
            Colors.orange,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatCard(
            'Progress',
            '${percentage.toStringAsFixed(1)}',
            '%',
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
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

  Widget _buildWaterLogs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Intake',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _setDailyGoal,
              child: Text('Set Goal'),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _waterLogs.isEmpty
          ? Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No water logged today. Start hydrating!',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _waterLogs.length,
              itemBuilder: (context, index) {
                final log = _waterLogs[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 2.w),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.water_drop,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${log['amount'].toInt()} ml',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              log['type'],
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        log['time'],
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }
}