import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';
import 'supabase_service.dart';

class FitnessService {
  static FitnessService? _instance;
  static FitnessService get instance => _instance ??= FitnessService._();

  FitnessService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // User Profile Management
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> data) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('user_profiles')
          .update(data)
          .eq('id', user.id)
          .select()
          .single();
      return response;
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
      var query = _client.from('exercises').select();

      if (category != null) {
        query = query.eq('category', category);
      }
      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      final response =
          await query.order('name', ascending: true).limit(limit ?? 50);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get exercises: $error');
    }
  }

  Future<Map<String, dynamic>?> getExerciseById(String exerciseId) async {
    try {
      final response = await _client
          .from('exercises')
          .select()
          .eq('id', exerciseId)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to get exercise: $error');
    }
  }

  // Workout Plans
  Future<List<Map<String, dynamic>>> getUserWorkoutPlans() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('workout_plans')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get workout plans: $error');
    }
  }

  Future<Map<String, dynamic>> createWorkoutPlan(
      Map<String, dynamic> planData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      planData['user_id'] = user.id;

      final response = await _client
          .from('workout_plans')
          .insert(planData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create workout plan: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutPlanExercises(
      String planId) async {
    try {
      final response = await _client
          .from('workout_plan_exercises')
          .select('*, exercises(*)')
          .eq('workout_plan_id', planId)
          .order('day_number', ascending: true)
          .order('order_in_day', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get workout plan exercises: $error');
    }
  }

  // Workout Sessions
  Future<Map<String, dynamic>> startWorkoutSession(
      Map<String, dynamic> sessionData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      sessionData['user_id'] = user.id;
      sessionData['status'] = 'active';
      sessionData['started_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('workout_sessions')
          .insert(sessionData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to start workout session: $error');
    }
  }

  Future<Map<String, dynamic>> completeWorkoutSession(String sessionId,
      {int? durationMinutes, int? caloriesBurned, String? notes}) async {
    try {
      final updateData = <String, dynamic>{
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
      };

      if (durationMinutes != null)
        updateData['duration_minutes'] = durationMinutes;
      if (caloriesBurned != null)
        updateData['calories_burned'] = caloriesBurned;
      if (notes != null) updateData['notes'] = notes;

      final response = await _client
          .from('workout_sessions')
          .update(updateData)
          .eq('id', sessionId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to complete workout session: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getUserWorkoutSessions(
      {int? limit}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('workout_sessions')
          .select('*, workout_plans(name)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit ?? 20);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get workout sessions: $error');
    }
  }

  // Exercise Sets
  Future<Map<String, dynamic>> addExerciseSet(
      Map<String, dynamic> setData) async {
    try {
      final response =
          await _client.from('exercise_sets').insert(setData).select().single();
      return response;
    } catch (error) {
      throw Exception('Failed to add exercise set: $error');
    }
  }

  Future<Map<String, dynamic>> updateExerciseSet(
      String setId, Map<String, dynamic> updateData) async {
    try {
      final response = await _client
          .from('exercise_sets')
          .update(updateData)
          .eq('id', setId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update exercise set: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getSessionExerciseSets(
      String sessionId) async {
    try {
      final response = await _client
          .from('exercise_sets')
          .select('*, exercises(name)')
          .eq('workout_session_id', sessionId)
          .order('exercise_id', ascending: true)
          .order('set_number', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get exercise sets: $error');
    }
  }

  // Body Measurements
  Future<Map<String, dynamic>> addBodyMeasurement(
      Map<String, dynamic> measurementData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      measurementData['user_id'] = user.id;

      final response = await _client
          .from('body_measurements')
          .insert(measurementData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to add body measurement: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getBodyMeasurements(String measurementType,
      {int? limit}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('body_measurements')
          .select()
          .eq('user_id', user.id)
          .eq('measurement_type', measurementType)
          .order('measured_at', ascending: false)
          .limit(limit ?? 30);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get body measurements: $error');
    }
  }

  // User Goals
  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> goalData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      goalData['user_id'] = user.id;

      final response =
          await _client.from('user_goals').insert(goalData).select().single();
      return response;
    } catch (error) {
      throw Exception('Failed to create goal: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getUserGoals() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('user_goals')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user goals: $error');
    }
  }

  Future<Map<String, dynamic>> updateGoalProgress(
      String goalId, double currentValue) async {
    try {
      final response = await _client
          .from('user_goals')
          .update({'current_value': currentValue})
          .eq('id', goalId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update goal progress: $error');
    }
  }

  // Nutrition Logging
  Future<Map<String, dynamic>> logNutrition(
      Map<String, dynamic> nutritionData) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      nutritionData['user_id'] = user.id;

      final response = await _client
          .from('nutrition_logs')
          .insert(nutritionData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to log nutrition: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getNutritionLogs(DateTime date,
      {String? mealType}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = startDate.add(const Duration(days: 1));

      var query = _client
          .from('nutrition_logs')
          .select()
          .eq('user_id', user.id)
          .gte('logged_at', startDate.toIso8601String())
          .lt('logged_at', endDate.toIso8601String());

      if (mealType != null) {
        query = query.eq('meal_type', mealType);
      }

      final response = await query.order('logged_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get nutrition logs: $error');
    }
  }

  // Statistics and Analytics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get workout stats
      final workoutData = await _client
          .from('workout_sessions')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'completed')
          .count();

      // Get total exercise sets completed
      final setsData = await _client
          .from('exercise_sets')
          .select('id')
          .eq('completed', true);

      // Get latest weight measurement
      final weightData = await _client
          .from('body_measurements')
          .select('value')
          .eq('user_id', user.id)
          .eq('measurement_type', 'weight')
          .order('measured_at', ascending: false)
          .limit(1);

      return {
        'completed_workouts': workoutData.count ?? 0,
        'total_sets_completed': setsData.length,
        'current_weight': weightData.isNotEmpty ? weightData[0]['value'] : null,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      throw Exception('Failed to get user stats: $error');
    }
  }
}