import 'dart:math';

class ExerciseRecommendationService {
  static ExerciseRecommendationService? _instance;
  static ExerciseRecommendationService get instance => _instance ??= ExerciseRecommendationService._();
  
  ExerciseRecommendationService._();

  // Comprehensive exercise database for sedentary lifestyle
  final Map<String, List<Map<String, dynamic>>> _exerciseDatabase = {
    'desk_friendly': [
      {
        'id': 'desk_pushup',
        'name': 'Desk Push-ups',
        'category': 'Strength',
        'difficulty': 'Beginner',
        'duration': 30,
        'sets': 3,
        'reps': 10,
        'description': 'Push against your desk to strengthen chest and arms',
        'instructions': [
          'Stand arm\\'s length from your desk',
          'Place palms flat against the desk edge',
          'Lean in toward the desk keeping body straight',
          'Push back to starting position',
          'Keep core engaged throughout'
        ],
        'targetMuscles': ['Chest', 'Triceps', 'Shoulders'],
        'equipment': 'Desk',
        'caloriesBurn': 25,
        'postureHelp': true,
        'stressRelief': false,
      },
      {
        'id': 'chair_dips',
        'name': 'Chair Dips',
        'category': 'Strength',
        'difficulty': 'Intermediate',
        'duration': 25,
        'sets': 3,
        'reps': 8,
        'description': 'Use your chair to work triceps and shoulders',
        'instructions': [
          'Sit on edge of sturdy chair',
          'Grip chair seat beside your hips',
          'Slide off chair, supporting weight with arms',
          'Lower body by bending elbows',
          'Push back up to starting position'
        ],
        'targetMuscles': ['Triceps', 'Shoulders', 'Core'],
        'equipment': 'Chair',
        'caloriesBurn': 20,
        'postureHelp': true,
        'stressRelief': false,
      },
      {
        'id': 'seated_leg_extensions',
        'name': 'Seated Leg Extensions',
        'category': 'Strength',
        'difficulty': 'Beginner',
        'duration': 20,
        'sets': 2,
        'reps': 15,
        'description': 'Strengthen your quadriceps while seated',
        'instructions': [
          'Sit up straight in your chair',
          'Grip chair sides for stability',
          'Extend one leg straight out',
          'Hold for 2 seconds',
          'Lower slowly and repeat'
        ],
        'targetMuscles': ['Quadriceps', 'Hip Flexors'],
        'equipment': 'Chair',
        'caloriesBurn': 15,
        'postureHelp': false,
        'stressRelief': false,
      }
    ],
    'posture_corrective': [
      {
        'id': 'neck_rolls',
        'name': 'Neck Rolls',
        'category': 'Flexibility',
        'difficulty': 'Beginner',
        'duration': 30,
        'sets': 1,
        'reps': 5,
        'description': 'Slowly roll your neck in circles to release tension',
        'instructions': [
          'Sit up straight with shoulders relaxed',
          'Drop your right ear toward right shoulder',
          'Slowly roll head down to center',
          'Continue to left shoulder',
          'Roll back to center and repeat'
        ],
        'targetMuscles': ['Neck', 'Upper Trapezius'],
        'equipment': 'None',
        'caloriesBurn': 5,
        'postureHelp': true,
        'stressRelief': true,
      },
      {
        'id': 'shoulder_blade_squeezes',
        'name': 'Shoulder Blade Squeezes',
        'category': 'Posture',
        'difficulty': 'Beginner',
        'duration': 15,
        'sets': 3,
        'reps': 10,
        'description': 'Strengthen upper back muscles',
        'instructions': [
          'Sit up tall with arms at your sides',
          'Squeeze shoulder blades together',
          'Hold for 5 seconds',
          'Release slowly',
          'Feel the stretch between shoulder blades'
        ],
        'targetMuscles': ['Rhomboids', 'Middle Trapezius'],
        'equipment': 'None',
        'caloriesBurn': 8,
        'postureHelp': true,
        'stressRelief': false,
      },
      {
        'id': 'spinal_twist',
        'name': 'Seated Spinal Twist',
        'category': 'Flexibility',
        'difficulty': 'Beginner',
        'duration': 30,
        'sets': 2,
        'reps': 5,
        'description': 'Rotate spine to improve mobility',
        'instructions': [
          'Sit up straight, feet flat on floor',
          'Place right hand on left knee',
          'Twist gently to the left',
          'Hold and breathe deeply',
          'Return to center and repeat other side'
        ],
        'targetMuscles': ['Obliques', 'Spinal Erectors'],
        'equipment': 'Chair',
        'caloriesBurn': 10,
        'postureHelp': true,
        'stressRelief': true,
      }
    ],
    'cardio_boost': [
      {
        'id': 'desk_marching',
        'name': 'Seated Marching',
        'category': 'Cardio',
        'difficulty': 'Beginner',
        'duration': 60,
        'sets': 1,
        'reps': 30,
        'description': 'March in place while seated to boost circulation',
        'instructions': [
          'Sit up straight in your chair',
          'Lift one knee up toward chest',
          'Lower and lift the other knee',
          'Keep a steady rhythm',
          'Pump arms gently if comfortable'
        ],
        'targetMuscles': ['Hip Flexors', 'Core'],
        'equipment': 'Chair',
        'caloriesBurn': 20,
        'postureHelp': false,
        'stressRelief': false,
      },
      {
        'id': 'calf_raises',
        'name': 'Calf Raises',
        'category': 'Cardio',
        'difficulty': 'Beginner',
        'duration': 30,
        'sets': 3,
        'reps': 20,
        'description': 'Improve circulation and strengthen calves',
        'instructions': [
          'Stand with feet hip-width apart',
          'Rise up onto balls of feet',
          'Hold for 2 seconds',
          'Lower slowly',
          'Feel the stretch in your calves'
        ],
        'targetMuscles': ['Calves', 'Ankles'],
        'equipment': 'None',
        'caloriesBurn': 15,
        'postureHelp': false,
        'stressRelief': false,
      }
    ],
    'stress_relief': [
      {
        'id': 'deep_breathing',
        'name': 'Deep Breathing Exercise',
        'category': 'Relaxation',
        'difficulty': 'Beginner',
        'duration': 120,
        'sets': 1,
        'reps': 10,
        'description': 'Mindful breathing exercises to reduce stress',
        'instructions': [
          'Sit comfortably with eyes closed',
          'Inhale slowly through nose for 4 counts',
          'Hold breath for 4 counts',
          'Exhale slowly through mouth for 6 counts',
          'Focus on the rhythm of your breathing'
        ],
        'targetMuscles': ['Diaphragm'],
        'equipment': 'None',
        'caloriesBurn': 5,
        'postureHelp': false,
        'stressRelief': true,
      },
      {
        'id': 'progressive_muscle_relaxation',
        'name': 'Progressive Muscle Relaxation',
        'category': 'Relaxation',
        'difficulty': 'Beginner',
        'duration': 180,
        'sets': 1,
        'reps': 1,
        'description': 'Systematically tense and relax muscle groups',
        'instructions': [
          'Start with your toes, tense for 5 seconds',
          'Release and feel the relaxation',
          'Move up to calves, thighs, abdomen',
          'Continue with arms, shoulders, neck',
          'End with facial muscles and full body scan'
        ],
        'targetMuscles': ['Full Body'],
        'equipment': 'None',
        'caloriesBurn': 10,
        'postureHelp': false,
        'stressRelief': true,
      }
    ],
    'energy_boost': [
      {
        'id': 'desk_jumping_jacks',
        'name': 'Modified Jumping Jacks',
        'category': 'Cardio',
        'difficulty': 'Intermediate',
        'duration': 30,
        'sets': 2,
        'reps': 15,
        'description': 'Energizing movement while standing at desk',
        'instructions': [
          'Stand behind your chair',
          'Jump feet apart while raising arms',
          'Jump feet together while lowering arms',
          'Land softly to avoid noise',
          'Keep movements controlled'
        ],
        'targetMuscles': ['Full Body', 'Cardiovascular'],
        'equipment': 'None',
        'caloriesBurn': 25,
        'postureHelp': false,
        'stressRelief': false,
      }
    ]
  };

  // Workout templates for different goals
  final Map<String, Map<String, dynamic>> _workoutTemplates = {
    'quick_energizer': {
      'name': 'Quick Energy Boost',
      'duration': 5,
      'description': 'Short workout to boost energy and focus',
      'exercises': ['neck_rolls', 'shoulder_blade_squeezes', 'calf_raises', 'deep_breathing'],
      'target': 'Energy & Focus'
    },
    'posture_fix': {
      'name': 'Posture Correction',
      'duration': 8,
      'description': 'Targeted exercises to improve posture',
      'exercises': ['neck_rolls', 'shoulder_blade_squeezes', 'spinal_twist', 'desk_pushup'],
      'target': 'Posture Improvement'
    },
    'stress_buster': {
      'name': 'Stress Relief Session',
      'duration': 10,
      'description': 'Relaxation exercises to reduce stress',
      'exercises': ['deep_breathing', 'neck_rolls', 'spinal_twist', 'progressive_muscle_relaxation'],
      'target': 'Stress Relief'
    },
    'circulation_booster': {
      'name': 'Circulation Activator',
      'duration': 6,
      'description': 'Get blood flowing with movement',
      'exercises': ['desk_marching', 'calf_raises', 'seated_leg_extensions', 'desk_jumping_jacks'],
      'target': 'Circulation'
    },
    'full_desk_workout': {
      'name': 'Complete Desk Workout',
      'duration': 15,
      'description': 'Comprehensive workout for desk workers',
      'exercises': ['neck_rolls', 'shoulder_blade_squeezes', 'desk_pushup', 'chair_dips', 'seated_leg_extensions', 'spinal_twist', 'calf_raises', 'deep_breathing'],
      'target': 'Complete Fitness'
    }
  };

  /// Get personalized exercise recommendations based on user profile and current context
  List<Map<String, dynamic>> getPersonalizedRecommendations({
    String? fitnessGoal,
    String? activityLevel,
    int? availableMinutes,
    String? currentMood,
    bool? hasPostureIssues,
    bool? needsEnergyBoost,
    bool? isStressed,
  }) {
    List<Map<String, dynamic>> recommendations = [];
    
    // Determine primary need
    String primaryNeed = _determinePrimaryNeed(
      fitnessGoal: fitnessGoal,
      currentMood: currentMood,
      hasPostureIssues: hasPostureIssues,
      needsEnergyBoost: needsEnergyBoost,
      isStressed: isStressed,
    );
    
    // Get base exercises for primary need
    List<Map<String, dynamic>> baseExercises = _getExercisesForNeed(primaryNeed);
    
    // Filter by available time
    if (availableMinutes != null) {
      baseExercises = baseExercises.where((exercise) => 
        (exercise['duration'] as int) <= (availableMinutes * 60)
      ).toList();
    }
    
    // Filter by activity level
    if (activityLevel != null) {
      baseExercises = _filterByActivityLevel(baseExercises, activityLevel);
    }
    
    // Add variety and randomization
    baseExercises.shuffle();
    
    return baseExercises.take(6).toList();
  }

  /// Get a complete workout plan based on available time and goals
  Map<String, dynamic> getWorkoutPlan({
    required int availableMinutes,
    String? primaryGoal,
    String? activityLevel,
  }) {
    // Select appropriate template
    String templateKey = _selectWorkoutTemplate(availableMinutes, primaryGoal);
    Map<String, dynamic> template = Map.from(_workoutTemplates[templateKey]!);
    
    // Get actual exercise objects
    List<Map<String, dynamic>> exercises = [];
    for (String exerciseId in template['exercises']) {
      Map<String, dynamic>? exercise = _findExerciseById(exerciseId);
      if (exercise != null) {
        exercises.add(exercise);
      }
    }
    
    // Adjust for activity level
    if (activityLevel != null) {
      exercises = _adjustForActivityLevel(exercises, activityLevel);
    }
    
    template['exerciseObjects'] = exercises;
    template['totalCalories'] = exercises.fold<int>(0, (sum, ex) => sum + (ex['caloriesBurn'] as int));
    
    return template;
  }

  /// Get exercises filtered by category
  List<Map<String, dynamic>> getExercisesByCategory(String category) {
    List<Map<String, dynamic>> allExercises = [];
    
    for (List<Map<String, dynamic>> categoryExercises in _exerciseDatabase.values) {
      allExercises.addAll(categoryExercises.where((exercise) => 
        exercise['category'].toString().toLowerCase() == category.toLowerCase()
      ));
    }
    
    return allExercises;
  }

  /// Get exercises that help with specific issues
  List<Map<String, dynamic>> getExercisesForIssue(String issue) {
    List<Map<String, dynamic>> exercises = [];
    
    switch (issue.toLowerCase()) {
      case 'posture':
        exercises = getAllExercises().where((ex) => ex['postureHelp'] == true).toList();
        break;
      case 'stress':
        exercises = getAllExercises().where((ex) => ex['stressRelief'] == true).toList();
        break;
      case 'energy':
        exercises = getExercisesByCategory('Cardio');
        break;
      case 'flexibility':
        exercises = getExercisesByCategory('Flexibility');
        break;
      default:
        exercises = getRandomExercises(6);
    }
    
    return exercises;
  }

  /// Get all exercises from the database
  List<Map<String, dynamic>> getAllExercises() {
    List<Map<String, dynamic>> allExercises = [];
    for (List<Map<String, dynamic>> categoryExercises in _exerciseDatabase.values) {
      allExercises.addAll(categoryExercises);
    }
    return allExercises;
  }

  /// Get random selection of exercises
  List<Map<String, dynamic>> getRandomExercises(int count) {
    List<Map<String, dynamic>> allExercises = getAllExercises();
    allExercises.shuffle();
    return allExercises.take(count).toList();
  }

  /// Get exercise by ID
  Map<String, dynamic>? getExerciseById(String id) {
    return _findExerciseById(id);
  }

  /// Get all workout templates
  Map<String, Map<String, dynamic>> getWorkoutTemplates() {
    return Map.from(_workoutTemplates);
  }

  // Private helper methods
  
  String _determinePrimaryNeed({
    String? fitnessGoal,
    String? currentMood,
    bool? hasPostureIssues,
    bool? needsEnergyBoost,
    bool? isStressed,
  }) {
    if (isStressed == true) return 'stress_relief';
    if (hasPostureIssues == true) return 'posture_corrective';
    if (needsEnergyBoost == true) return 'energy_boost';
    if (fitnessGoal == 'Posture Improvement') return 'posture_corrective';
    
    return 'desk_friendly';
  }
  
  List<Map<String, dynamic>> _getExercisesForNeed(String need) {
    return _exerciseDatabase[need] ?? _exerciseDatabase['desk_friendly']!;
  }
  
  List<Map<String, dynamic>> _filterByActivityLevel(List<Map<String, dynamic>> exercises, String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
      case 'light':
        return exercises.where((ex) => ex['difficulty'] == 'Beginner').toList();
      case 'moderate':
        return exercises.where((ex) => ['Beginner', 'Intermediate'].contains(ex['difficulty'])).toList();
      case 'active':
      case 'very active':
        return exercises; // No filtering for active users
      default:
        return exercises;
    }
  }
  
  String _selectWorkoutTemplate(int availableMinutes, String? primaryGoal) {
    if (availableMinutes <= 5) {
      return 'quick_energizer';
    } else if (availableMinutes <= 8) {
      if (primaryGoal == 'Posture Improvement') return 'posture_fix';
      return 'circulation_booster';
    } else if (availableMinutes <= 12) {
      if (primaryGoal == 'Stress Relief') return 'stress_buster';
      return 'posture_fix';
    } else {
      return 'full_desk_workout';
    }
  }
  
  Map<String, dynamic>? _findExerciseById(String id) {
    for (List<Map<String, dynamic>> categoryExercises in _exerciseDatabase.values) {
      for (Map<String, dynamic> exercise in categoryExercises) {
        if (exercise['id'] == id) {
          return Map.from(exercise);
        }
      }
    }
    return null;
  }
  
  List<Map<String, dynamic>> _adjustForActivityLevel(List<Map<String, dynamic>> exercises, String activityLevel) {
    List<Map<String, dynamic>> adjustedExercises = [];
    
    for (Map<String, dynamic> exercise in exercises) {
      Map<String, dynamic> adjusted = Map.from(exercise);
      
      switch (activityLevel.toLowerCase()) {
        case 'sedentary':
          adjusted['sets'] = (adjusted['sets'] as int) - 1;
          adjusted['reps'] = ((adjusted['reps'] as int) * 0.8).round();
          break;
        case 'light':
          adjusted['reps'] = ((adjusted['reps'] as int) * 0.9).round();
          break;
        case 'active':
          adjusted['sets'] = (adjusted['sets'] as int) + 1;
          break;
        case 'very active':
          adjusted['sets'] = (adjusted['sets'] as int) + 1;
          adjusted['reps'] = ((adjusted['reps'] as int) * 1.2).round();
          break;
      }
      
      // Ensure minimum values
      adjusted['sets'] = (adjusted['sets'] as int).clamp(1, 5);
      adjusted['reps'] = (adjusted['reps'] as int).clamp(3, 30);
      
      adjustedExercises.add(adjusted);
    }
    
    return adjustedExercises;
  }
}