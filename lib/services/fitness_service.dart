import './mock_data_service.dart';

class FitnessService {
  static FitnessService? _instance;
  static FitnessService get instance => _instance ??= FitnessService._();

  FitnessService._();

  MockDataService get _mockService => MockDataService.instance;

  // User Profile Management
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      await Future.delayed(Duration(milliseconds: 300)); // Simulate network delay
      return _mockService.getUserProfile();
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> data) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      return _mockService.updateUserProfile(data);
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Exercise Management
  Future<List<Map<String, dynamic>>> getExercises({
    String? category,
    String? difficulty,
    int? limit,
  }) async {
    try {
      await Future.delayed(Duration(milliseconds: 400));
      return _mockService.getExercises(
        category: category,
        difficulty: difficulty,
        limit: limit,
      );
    } catch (error) {
      throw Exception('Failed to get exercises: $error');
    }
  }

  Future<Map<String, dynamic>?> getExerciseById(String exerciseId) async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      return _mockService.getExerciseById(exerciseId);
    } catch (error) {
      throw Exception('Failed to get exercise: $error');
    }
  }

  // Workout Plans
  Future<List<Map<String, dynamic>>> getUserWorkoutPlans() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      return _mockService.getUserWorkoutPlans();
    } catch (error) {
      throw Exception('Failed to get workout plans: $error');
    }
  }

  Future<Map<String, dynamic>> createWorkoutPlan(
      Map<String, dynamic> planData) async {
    try {
      await Future.delayed(Duration(milliseconds: 600));
      return _mockService.createWorkoutPlan(planData);
    } catch (error) {
      throw Exception('Failed to create workout plan: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutPlanExercises(
      String planId) async {
    try {
      await Future.delayed(Duration(milliseconds: 250));
      // Mock implementation - return some exercises for the plan
      return _mockService.getExercises(limit: 5);
    } catch (error) {
      throw Exception('Failed to get workout plan exercises: $error');
    }
  }

  // Workout Sessions
  Future<Map<String, dynamic>> startWorkoutSession(
      Map<String, dynamic> sessionData) async {
    try {
      await Future.delayed(Duration(milliseconds: 400));
      return _mockService.startWorkoutSession(sessionData);
    } catch (error) {
      throw Exception('Failed to start workout session: $error');
    }
  }

  Future<Map<String, dynamic>> completeWorkoutSession(String sessionId,
      {int? durationMinutes, int? caloriesBurned, String? notes}) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      // Mock implementation - return completed session
      return {
        'id': sessionId,
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'duration_minutes': durationMinutes ?? 30,
        'calories_burned': caloriesBurned ?? 150,
        'notes': notes,
      };
    } catch (error) {
      throw Exception('Failed to complete workout session: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getUserWorkoutSessions(
      {int? limit}) async {
    try {
      await Future.delayed(Duration(milliseconds: 350));
      return _mockService.getUserWorkoutSessions(limit: limit);
    } catch (error) {
      throw Exception('Failed to get workout sessions: $error');
    }
  }

  // Exercise Sets
  Future<Map<String, dynamic>> addExerciseSet(
      Map<String, dynamic> setData) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      return {
        'id': 'set${DateTime.now().millisecondsSinceEpoch}',
        'created_at': DateTime.now().toIso8601String(),
        ...setData,
      };
    } catch (error) {
      throw Exception('Failed to add exercise set: $error');
    }
  }

  Future<Map<String, dynamic>> updateExerciseSet(
      String setId, Map<String, dynamic> updateData) async {
    try {
      await Future.delayed(Duration(milliseconds: 250));
      return {
        'id': setId,
        'updated_at': DateTime.now().toIso8601String(),
        ...updateData,
      };
    } catch (error) {
      throw Exception('Failed to update exercise set: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getSessionExerciseSets(
      String sessionId) async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      // Mock implementation - return some sets
      return [
        {
          'id': 'set1',
          'exercise_id': 'ex1',
          'set_number': 1,
          'reps': 10,
          'weight': 20,
          'exercises': {'name': 'Push-ups'},
        },
        {
          'id': 'set2',
          'exercise_id': 'ex1',
          'set_number': 2,
          'reps': 8,
          'weight': 20,
          'exercises': {'name': 'Push-ups'},
        },
      ];
    } catch (error) {
      throw Exception('Failed to get exercise sets: $error');
    }
  }

  // Body Measurements
  Future<Map<String, dynamic>> addBodyMeasurement(
      Map<String, dynamic> measurementData) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      return {
        'id': 'measure${DateTime.now().millisecondsSinceEpoch}',
        'user_id': _mockService.currentUser?['id'],
        'measured_at': DateTime.now().toIso8601String(),
        ...measurementData,
      };
    } catch (error) {
      throw Exception('Failed to add body measurement: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getBodyMeasurements(String measurementType,
      {int? limit}) async {
    try {
      await Future.delayed(Duration(milliseconds: 250));
      return _mockService.getBodyMeasurements(measurementType, limit: limit);
    } catch (error) {
      throw Exception('Failed to get body measurements: $error');
    }
  }

  // User Goals
  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> goalData) async {
    try {
      await Future.delayed(Duration(milliseconds: 400));
      return _mockService.createGoal(goalData);
    } catch (error) {
      throw Exception('Failed to create goal: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getUserGoals() async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      return _mockService.getUserGoals();
    } catch (error) {
      throw Exception('Failed to get user goals: $error');
    }
  }

  Future<Map<String, dynamic>> updateGoalProgress(
      String goalId, double currentValue) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      return {
        'id': goalId,
        'current_value': currentValue,
        'updated_at': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      throw Exception('Failed to update goal progress: $error');
    }
  }

  // Nutrition Logging
  Future<Map<String, dynamic>> logNutrition(
      Map<String, dynamic> nutritionData) async {
    try {
      await Future.delayed(Duration(milliseconds: 300));
      return {
        'id': 'nutrition${DateTime.now().millisecondsSinceEpoch}',
        'user_id': _mockService.currentUser?['id'],
        'logged_at': DateTime.now().toIso8601String(),
        ...nutritionData,
      };
    } catch (error) {
      throw Exception('Failed to log nutrition: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getNutritionLogs(DateTime date,
      {String? mealType}) async {
    try {
      await Future.delayed(Duration(milliseconds: 200));
      return _mockService.getNutritionLogs(date, mealType: mealType);
    } catch (error) {
      throw Exception('Failed to get nutrition logs: $error');
    }
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      await Future.delayed(Duration(milliseconds: 400));
      return _mockService.getUserStats();
    } catch (error) {
      throw Exception('Failed to get user stats: $error');
    }
  }
}