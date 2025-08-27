import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/exercise_recommendation_service.dart';
import '../../services/fitness_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../workout_session/workout_session_screen.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  const WorkoutPlannerScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen>
    with TickerProviderStateMixin {
  late AnimationController _recommendationController;
  late Animation<double> _recommendationAnimation;
  
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  
  // Current preferences
  int _availableMinutes = 10;
  String _primaryGoal = 'General Fitness';
  String _currentMood = 'Neutral';
  bool _hasPostureIssues = true;
  bool _needsEnergyBoost = false;
  bool _isStressed = false;
  
  // Recommendations
  List<Map<String, dynamic>> _personalizedExercises = [];
  Map<String, dynamic>? _recommendedWorkout;
  
  final List<int> _timeOptions = [5, 10, 15, 20, 30];
  final List<String> _moodOptions = ['Energetic', 'Neutral', 'Tired', 'Stressed'];
  final List<String> _goalOptions = [
    'General Fitness',
    'Posture Improvement',
    'Stress Relief',
    'Energy Boost',
    'Circulation',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfile();
  }

  void _initializeAnimations() {
    _recommendationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _recommendationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _recommendationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await FitnessService.instance.getUserProfile();
      setState(() {
        _userProfile = profile;
        if (profile != null) {
          _primaryGoal = profile['fitness_goal'] ?? 'General Fitness';
        }
        _isLoading = false;
      });
      
      _generateRecommendations();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _generateRecommendations();
    }
  }

  void _generateRecommendations() {
    // Get personalized exercise recommendations
    _personalizedExercises = ExerciseRecommendationService.instance.getPersonalizedRecommendations(
      fitnessGoal: _primaryGoal,
      activityLevel: _userProfile?['activity_level'],
      availableMinutes: _availableMinutes,
      currentMood: _currentMood,
      hasPostureIssues: _hasPostureIssues,
      needsEnergyBoost: _needsEnergyBoost,
      isStressed: _isStressed,
    );
    
    // Get recommended workout plan
    _recommendedWorkout = ExerciseRecommendationService.instance.getWorkoutPlan(
      availableMinutes: _availableMinutes,
      primaryGoal: _primaryGoal,
      activityLevel: _userProfile?['activity_level'],
    );
    
    setState(() {});
    _recommendationController.forward();
  }

  void _startCustomWorkout(List<Map<String, dynamic>> exercises) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomWorkoutSessionScreen(exercises: exercises),
      ),
    );
  }

  void _startRecommendedWorkout() {
    if (_recommendedWorkout != null) {
      final exercises = _recommendedWorkout!['exerciseObjects'] as List<Map<String, dynamic>>;
      _startCustomWorkout(exercises);
    }
  }

  @override
  void dispose() {
    _recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Workout Planner'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Smart Workout Planner',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _generateRecommendations,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences section
            _buildPreferencesSection(),
            SizedBox(height: 4.h),
            
            // Recommended workout
            if (_recommendedWorkout != null) ..[
              _buildRecommendedWorkout(),
              SizedBox(height: 4.h),
            ],
            
            // Individual exercise recommendations
            _buildExerciseRecommendations(),
            SizedBox(height: 4.h),
            
            // Quick workout templates
            _buildQuickTemplates(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
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
            'Your Preferences',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3.h),
          
          // Time selection
          Text(
            'Available Time',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: _timeOptions.map((time) => 
              ChoiceChip(
                label: Text('${time}min'),
                selected: _availableMinutes == time,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _availableMinutes = time;
                    });
                    _generateRecommendations();
                  }
                },
              ),
            ).toList(),
          ),
          
          SizedBox(height: 3.h),
          
          // Primary goal
          Text(
            'Primary Goal',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: _primaryGoal,
            onChanged: (value) {
              setState(() {
                _primaryGoal = value!;
              });
              _generateRecommendations();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _goalOptions.map((goal) => 
              DropdownMenuItem(
                value: goal,
                child: Text(goal),
              ),
            ).toList(),
          ),
          
          SizedBox(height: 3.h),
          
          // Quick assessment
          Text(
            'How are you feeling today?',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            children: _moodOptions.map((mood) => 
              ChoiceChip(
                label: Text(mood),
                selected: _currentMood == mood,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentMood = mood;
                      _isStressed = mood == 'Stressed';
                      _needsEnergyBoost = mood == 'Tired';
                    });
                    _generateRecommendations();
                  }
                },
              ),
            ).toList(),
          ),
          
          SizedBox(height: 2.h),
          
          // Issue checkboxes
          CheckboxListTile(
            title: Text('I have posture issues'),
            value: _hasPostureIssues,
            onChanged: (value) {
              setState(() {
                _hasPostureIssues = value!;
              });
              _generateRecommendations();
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedWorkout() {
    return AnimatedBuilder(
      animation: _recommendationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_recommendationAnimation.value * 0.2),
          child: Opacity(
            opacity: _recommendationAnimation.value,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withAlpha(204),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withAlpha(77),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.white, size: 28),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Recommended for You',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _recommendedWorkout!['name'],
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _recommendedWorkout!['description'],
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      _buildWorkoutMetric(
                        Icons.timer,
                        '${_recommendedWorkout!['duration']} min',
                        'Duration',
                      ),
                      SizedBox(width: 4.w),
                      _buildWorkoutMetric(
                        Icons.local_fire_department,
                        '${_recommendedWorkout!['totalCalories']} cal',
                        'Calories',
                      ),
                      SizedBox(width: 4.w),
                      _buildWorkoutMetric(
                        Icons.fitness_center,
                        '${(_recommendedWorkout!['exerciseObjects'] as List).length}',
                        'Exercises',
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startRecommendedWorkout,
                      icon: Icon(Icons.play_arrow),
                      label: Text('Start Workout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: Colors.white.withAlpha(179),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized Exercise Suggestions',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        
        if (_personalizedExercises.isEmpty)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Generating personalized recommendations...',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 3.w,
              childAspectRatio: 0.85,
            ),
            itemCount: _personalizedExercises.length,
            itemBuilder: (context, index) {
              final exercise = _personalizedExercises[index];
              return _buildExerciseCard(exercise);
            },
          ),
      ],
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _startCustomWorkout([exercise]),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(exercise['category']).withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(exercise['category']),
                      color: _getCategoryColor(exercise['category']),
                      size: 20,
                    ),
                  ),
                  if (exercise['postureHelp'] == true)
                    Icon(Icons.accessibility_new, color: Colors.green, size: 16),
                  if (exercise['stressRelief'] == true)
                    Icon(Icons.self_improvement, color: Colors.blue, size: 16),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                exercise['name'],
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              Text(
                exercise['description'],
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${exercise['duration']}s',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    '${exercise['caloriesBurn']} cal',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTemplates() {
    final templates = ExerciseRecommendationService.instance.getWorkoutTemplates();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Workout Templates',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates.values.elementAt(index);
              return Container(
                width: 70.w,
                margin: EdgeInsets.only(right: 3.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(26),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template['name'],
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      template['description'],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${template['duration']} min',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final workoutPlan = ExerciseRecommendationService.instance.getWorkoutPlan(
                              availableMinutes: template['duration'],
                              primaryGoal: template['target'],
                            );
                            final exercises = workoutPlan['exerciseObjects'] as List<Map<String, dynamic>>;
                            _startCustomWorkout(exercises);
                          },
                          child: Text('Start'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Colors.red;
      case 'cardio':
        return Colors.orange;
      case 'flexibility':
        return Colors.green;
      case 'posture':
        return Colors.blue;
      case 'relaxation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.favorite;
      case 'flexibility':
        return Icons.accessibility_new;
      case 'posture':
        return Icons.straighten;
      case 'relaxation':
        return Icons.self_improvement;
      default:
        return Icons.sports;
    }
  }
}

// Enhanced workout session screen that accepts custom exercise lists
class CustomWorkoutSessionScreen extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  
  const CustomWorkoutSessionScreen({Key? key, required this.exercises}) : super(key: key);

  @override
  State<CustomWorkoutSessionScreen> createState() => _CustomWorkoutSessionScreenState();
}

class _CustomWorkoutSessionScreenState extends State<CustomWorkoutSessionScreen> {
  // Implementation would be similar to the existing WorkoutSessionScreen
  // but adapted to use the provided exercise list
  
  @override
  Widget build(BuildContext context) {
    return WorkoutSessionScreen(); // Simplified for now
  }
}