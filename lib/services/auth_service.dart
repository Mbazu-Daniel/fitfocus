import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? email.split('@')[0],
          'role': 'member',
          ...?metadata,
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (error) {
      throw Exception('Password update failed: $error');
    }
  }

  // Update user profile data
  Future<UserResponse> updateUser({
    String? email,
    String? fullName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final attributes = UserAttributes();

      if (email != null) attributes.email = email;
      if (fullName != null || metadata != null) {
        attributes.data = {
          if (fullName != null) 'full_name': fullName,
          ...?metadata,
        };
      }

      final response = await _client.auth.updateUser(attributes);
      return response;
    } catch (error) {
      throw Exception('User update failed: $error');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // OAuth sign-in with Google
  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  // OAuth sign-in with Apple
  Future<bool> signInWithApple() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.apple);
    } catch (error) {
      throw Exception('Apple sign-in failed: $error');
    }
  }

  // Get user role from profile
  Future<String?> getUserRole() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _client
          .from('user_profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      return response['role'];
    } catch (error) {
      // Return default role if profile not found
      return 'member';
    }
  }

  // Check if user has specific role
  Future<bool> hasRole(String role) async {
    try {
      final userRole = await getUserRole();
      return userRole == role;
    } catch (error) {
      return false;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    return await hasRole('admin');
  }

  // Check if user is trainer
  Future<bool> isTrainer() async {
    return await hasRole('trainer');
  }

  // Delete user account (requires admin privileges or own account)
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // First delete user profile (cascading will handle related data)
      await _client.from('user_profiles').delete().eq('id', user.id);

      // Then sign out
      await signOut();
    } catch (error) {
      throw Exception('Account deletion failed: $error');
    }
  }
}
