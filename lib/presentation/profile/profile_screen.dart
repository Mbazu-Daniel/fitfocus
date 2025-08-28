import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/fitness_service.dart';
import '../../widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Editable profile fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  
  String _selectedGender = 'Other';
  String _activityLevel = 'Moderate';
  String _fitnessGoal = 'General Fitness';
  
  // App settings
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  
  // FitFocus specific settings
  int _dailyStepGoal = 10000;
  int _waterReminderInterval = 60; // minutes
  int _pomodoroWorkDuration = 25; // minutes
  int _pomodoroBreakDuration = 5; // minutes
  int _postureReminderInterval = 30; // minutes
  bool _autoStartBreaks = false;
  bool _weekendReminders = true;
  String _preferredWorkoutTime = 'Morning';
  
  final List<String> _workoutTimes = ['Morning', 'Afternoon', 'Evening', 'Night'];
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _activityLevels = ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'];
  final List<String> _fitnessGoals = [
    'Weight Loss',
    'Muscle Gain',
    'General Fitness',
    'Endurance',
    'Flexibility',
    'Posture Improvement',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserProfile();
    _loadAppSettings();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _ageController = TextEditingController();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await FitnessService.instance.getUserProfile();
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile['full_name'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _heightController.text = (profile['height']?.toString() ?? '');
          _weightController.text = (profile['weight']?.toString() ?? '');
          _ageController.text = (profile['age']?.toString() ?? '');
          _selectedGender = profile['gender'] ?? 'Other';
          _activityLevel = profile['activity_level'] ?? 'Moderate';
          _fitnessGoal = profile['fitness_goal'] ?? 'General Fitness';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      
      // FitFocus specific settings
      _dailyStepGoal = prefs.getInt('daily_step_goal') ?? 10000;
      _waterReminderInterval = prefs.getInt('water_reminder_interval') ?? 60;
      _pomodoroWorkDuration = prefs.getInt('pomodoro_work_duration') ?? 25;
      _pomodoroBreakDuration = prefs.getInt('pomodoro_break_duration') ?? 5;
      _postureReminderInterval = prefs.getInt('posture_reminder_interval') ?? 30;
      _autoStartBreaks = prefs.getBool('auto_start_breaks') ?? false;
      _weekendReminders = prefs.getBool('weekend_reminders') ?? true;
      _preferredWorkoutTime = prefs.getString('preferred_workout_time') ?? 'Morning';
    });
  }

  Future<void> _saveAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    
    // FitFocus specific settings
    await prefs.setInt('daily_step_goal', _dailyStepGoal);
    await prefs.setInt('water_reminder_interval', _waterReminderInterval);
    await prefs.setInt('pomodoro_work_duration', _pomodoroWorkDuration);
    await prefs.setInt('pomodoro_break_duration', _pomodoroBreakDuration);
    await prefs.setInt('posture_reminder_interval', _postureReminderInterval);
    await prefs.setBool('auto_start_breaks', _autoStartBreaks);
    await prefs.setBool('weekend_reminders', _weekendReminders);
    await prefs.setString('preferred_workout_time', _preferredWorkoutTime);
  }

  Future<void> _saveProfile() async {
    if (!_validateInputs()) return;
    
    try {
      final updateData = {
        'full_name': _nameController.text.trim(),
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'age': int.tryParse(_ageController.text),
        'gender': _selectedGender,
        'activity_level': _activityLevel,
        'fitness_goal': _fitnessGoal,
      };
      
      await FitnessService.instance.updateUserProfile(updateData);
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      await _loadUserProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter your name');
      return false;
    }
    
    if (_heightController.text.isNotEmpty) {
      final height = double.tryParse(_heightController.text);
      if (height == null || height < 50 || height > 250) {
        _showErrorSnackBar('Please enter a valid height (50-250 cm)');
        return false;
      }
    }
    
    if (_weightController.text.isNotEmpty) {
      final weight = double.tryParse(_weightController.text);
      if (weight == null || weight < 20 || weight > 300) {
        _showErrorSnackBar('Please enter a valid weight (20-300 kg)');
        return false;
      }
    }
    
    if (_ageController.text.isNotEmpty) {
      final age = int.tryParse(_ageController.text);
      if (age == null || age < 13 || age > 120) {
        _showErrorSnackBar('Please enter a valid age (13-120 years)');
        return false;
      }
    }
    
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            child: Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Profile'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
                _loadUserProfile(); // Reset to original values
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            _buildProfileHeader(),
            SizedBox(height: 4.h),
            
            // Personal information
            _buildPersonalInfoSection(),
            SizedBox(height: 4.h),
            
            // Fitness information
            _buildFitnessInfoSection(),
            SizedBox(height: 4.h),
            
            // App settings
            _buildAppSettingsSection(),
            SizedBox(height: 4.h),
            
            // Wellness settings
            _buildWellnessSettingsSection(),
            SizedBox(height: 4.h),
            
            // Data and Privacy
            _buildDataPrivacySection(),
            SizedBox(height: 4.h),
            
            // Quick actions
            _buildQuickActionsSection(),
            SizedBox(height: 4.h),
            
            // Sign out button
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
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
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withAlpha(51),
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userProfile?['full_name'] ?? 'User',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _userProfile?['email'] ?? 'No email',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white.withAlpha(204),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Member since ${DateTime.now().year}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person,
          enabled: _isEditing,
        ),
        SizedBox(height: 3.w),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          enabled: false, // Email typically shouldn't be editable
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                enabled: _isEditing,
                suffix: 'years',
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildDropdownField(
                value: _selectedGender,
                label: 'Gender',
                icon: Icons.person_outline,
                items: _genderOptions,
                onChanged: _isEditing ? (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                } : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFitnessInfoSection() {
    return _buildSection(
      title: 'Fitness Information',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _heightController,
                label: 'Height',
                icon: Icons.height,
                keyboardType: TextInputType.number,
                enabled: _isEditing,
                suffix: 'cm',
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight',
                icon: Icons.scale,
                keyboardType: TextInputType.number,
                enabled: _isEditing,
                suffix: 'kg',
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
        _buildDropdownField(
          value: _activityLevel,
          label: 'Activity Level',
          icon: Icons.directions_run,
          items: _activityLevels,
          onChanged: _isEditing ? (value) {
            setState(() {
              _activityLevel = value!;
            });
          } : null,
        ),
        SizedBox(height: 3.w),
        _buildDropdownField(
          value: _fitnessGoal,
          label: 'Fitness Goal',
          icon: Icons.emoji_events,
          items: _fitnessGoals,
          onChanged: _isEditing ? (value) {
            setState(() {
              _fitnessGoal = value!;
            });
          } : null,
        ),
      ],
    );
  }

  Widget _buildWellnessSettingsSection() {
    return _buildSection(
      title: 'Wellness Settings',
      children: [
        // Step Counter Settings
        _buildNumberInputTile(
          title: 'Daily Step Goal',
          subtitle: 'Your target steps per day',
          icon: Icons.directions_walk,
          value: _dailyStepGoal,
          min: 1000,
          max: 50000,
          step: 500,
          suffix: 'steps',
          onChanged: (value) {
            setState(() {
              _dailyStepGoal = value;
            });
            _saveAppSettings();
          },
        ),
        SizedBox(height: 2.h),
        
        // Water Reminder Settings
        _buildNumberInputTile(
          title: 'Water Reminder Interval',
          subtitle: 'How often to remind you to drink water',
          icon: Icons.water_drop,
          value: _waterReminderInterval,
          min: 15,
          max: 240,
          step: 15,
          suffix: 'minutes',
          onChanged: (value) {
            setState(() {
              _waterReminderInterval = value;
            });
            _saveAppSettings();
          },
        ),
        SizedBox(height: 2.h),
        
        // Pomodoro Work Duration
        _buildNumberInputTile(
          title: 'Focus Session Duration',
          subtitle: 'Length of each focus/work session',
          icon: Icons.timer,
          value: _pomodoroWorkDuration,
          min: 5,
          max: 60,
          step: 5,
          suffix: 'minutes',
          onChanged: (value) {
            setState(() {
              _pomodoroWorkDuration = value;
            });
            _saveAppSettings();
          },
        ),
        SizedBox(height: 2.h),
        
        // Pomodoro Break Duration
        _buildNumberInputTile(
          title: 'Break Duration',
          subtitle: 'Length of each break session',
          icon: Icons.free_breakfast,
          value: _pomodoroBreakDuration,
          min: 2,
          max: 30,
          step: 1,
          suffix: 'minutes',
          onChanged: (value) {
            setState(() {
              _pomodoroBreakDuration = value;
            });
            _saveAppSettings();
          },
        ),
        SizedBox(height: 2.h),
        
        // Posture Reminder Settings
        _buildNumberInputTile(
          title: 'Posture Reminder Interval',
          subtitle: 'How often to remind about posture',
          icon: Icons.accessibility_new,
          value: _postureReminderInterval,
          min: 10,
          max: 120,
          step: 10,
          suffix: 'minutes',
          onChanged: (value) {
            setState(() {
              _postureReminderInterval = value;
            });
            _saveAppSettings();
          },
        ),
        SizedBox(height: 2.h),
        
        // Preferred Workout Time
        _buildDropdownTile(
          title: 'Preferred Workout Time',
          subtitle: 'When you prefer to exercise',
          icon: Icons.schedule,
          value: _preferredWorkoutTime,
          items: _workoutTimes,
          onChanged: (value) {
            setState(() {
              _preferredWorkoutTime = value!;
            });
            _saveAppSettings();
          },
        ),
        SizedBox(height: 2.h),
        
        // Auto-start breaks
        _buildSwitchTile(
          title: 'Auto-start Breaks',
          subtitle: 'Automatically start break timer after work session',
          icon: Icons.play_arrow,
          value: _autoStartBreaks,
          onChanged: (value) {
            setState(() {
              _autoStartBreaks = value;
            });
            _saveAppSettings();
          },
        ),
        
        // Weekend reminders
        _buildSwitchTile(
          title: 'Weekend Reminders',
          subtitle: 'Receive wellness reminders on weekends',
          icon: Icons.weekend,
          value: _weekendReminders,
          onChanged: (value) {
            setState(() {
              _weekendReminders = value;
            });
            _saveAppSettings();
          },
        ),
      ],
    );
  }

  Widget _buildAppSettingsSection() {
    return _buildSection(
      title: 'App Settings',
      children: [
        _buildSwitchTile(
          title: 'Notifications',
          subtitle: 'Receive push notifications',
          icon: Icons.notifications,
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            _saveAppSettings();
          },
        ),
        _buildSwitchTile(
          title: 'Sound Effects',
          subtitle: 'Play sounds for timer and alerts',
          icon: Icons.volume_up,
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
            _saveAppSettings();
          },
        ),
        _buildSwitchTile(
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          icon: Icons.vibration,
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _vibrationEnabled = value;
            });
            _saveAppSettings();
          },
        ),
      ],
    );
  }

  Widget _buildDataPrivacySection() {
    return _buildSection(
      title: 'Data & Privacy',
      children: [
        _buildSettingsTile(
          title: 'Export Data',
          subtitle: 'Download your fitness and wellness data',
          icon: Icons.download,
          onTap: _exportUserData,
        ),
        _buildSettingsTile(
          title: 'Clear Cache',
          subtitle: 'Clear app cache and temporary files',
          icon: Icons.clear_all,
          onTap: _clearAppCache,
        ),
        _buildSettingsTile(
          title: 'Reset Settings',
          subtitle: 'Reset all settings to default values',
          icon: Icons.restore,
          onTap: _resetSettings,
          textColor: Colors.orange,
        ),
        _buildSettingsTile(
          title: 'Delete Account',
          subtitle: 'Permanently delete your account and data',
          icon: Icons.delete_forever,
          onTap: _deleteAccount,
          textColor: Colors.red,
        ),
      ],
    );
  }

  void _exportUserData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: Text('Your data export will be prepared and sent to your email address.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data export initiated. Check your email.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  void _clearAppCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache'),
        content: Text('This will clear temporary files and may improve app performance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear cache logic would go here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content: Text('This will reset all app settings to default values. Your profile data will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await _loadAppSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text('This will permanently delete your account and all associated data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show second confirmation
              _showDeleteConfirmation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you absolutely sure?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This will permanently delete:'),
            SizedBox(height: 1.h),
            Text('• Your profile and fitness data'),
            Text('• All workout history'),
            Text('• Wellness tracking data'),
            Text('• App preferences and settings'),
            SizedBox(height: 2.h),
            Text(
              'Type DELETE to confirm:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type DELETE here',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Handle confirmation text
              },
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deletion initiated'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildQuickActionsSection() {
    return _buildSection(
      title: 'Quick Actions',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Step Counter',
                Icons.directions_walk,
                Colors.purple,
                () => Navigator.pushNamed(context, AppRoutes.stepCounter),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                'Water Reminder',
                Icons.water_drop,
                Colors.blue,
                () => Navigator.pushNamed(context, AppRoutes.waterReminder),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Focus Timer',
                Icons.timer,
                Colors.orange,
                () => Navigator.pushNamed(context, AppRoutes.pomodoroTimer),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                'Posture Exercises',
                Icons.accessibility_new,
                Colors.green,
                () => Navigator.pushNamed(context, AppRoutes.postureExercises),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Progress Tracking',
                Icons.trending_up,
                Colors.teal,
                () => Navigator.pushNamed(context, AppRoutes.progressTracking),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                'Exercise Library',
                Icons.fitness_center,
                Colors.red,
                () => Navigator.pushNamed(context, AppRoutes.exerciseLibrary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
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
            title,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: onChanged != null ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildNumberInputTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required int value,
    required int min,
    required int max,
    required int step,
    required String suffix,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > min ? () => onChanged(value - step) : null,
                icon: Icon(Icons.remove_circle_outline),
                color: value > min ? Theme.of(context).primaryColor : Colors.grey,
                iconSize: 24,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  '$value $suffix',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + step) : null,
                icon: Icon(Icons.add_circle_outline),
                color: value < max ? Theme.of(context).primaryColor : Colors.grey,
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              underline: Container(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: Colors.black,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
            Icon(icon, color: color, size: 28),
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

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _signOut,
        icon: Icon(Icons.logout),
        label: Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}