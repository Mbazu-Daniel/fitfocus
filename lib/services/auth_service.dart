import './mock_data_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  MockDataService get _mockService => MockDataService.instance;

  // Get current user
  Map<String, dynamic>? get currentUser => _mockService.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _mockService.isAuthenticated;

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await _mockService.signUp(email, password, fullName);
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _mockService.signIn(email, password);
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _mockService.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _mockService.resetPassword(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      // Mock implementation - always succeeds
      await Future.delayed(Duration(milliseconds: 500));
      return true;
    } catch (error) {
      throw Exception('Password update failed: $error');
    }
  }

  // Update user profile data
  Future<bool> updateUser({
    String? email,
    String? fullName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Mock implementation - always succeeds
      await Future.delayed(Duration(milliseconds: 500));
      if (fullName != null && currentUser != null) {
        currentUser!['user_metadata'] = {
          ...?currentUser!['user_metadata'],
          'full_name': fullName,
        };
      }
      return true;
    } catch (error) {
      throw Exception('User update failed: $error');
    }
  }

  // OAuth sign-in with Google
  Future<bool> signInWithGoogle() async {
    try {
      return await _mockService.signInWithGoogle();
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  // OAuth sign-in with Apple
  Future<bool> signInWithApple() async {
    try {
      // Mock implementation - always succeeds
      await Future.delayed(Duration(milliseconds: 1000));
      return await _mockService.signInWithGoogle(); // Use same mock as Google
    } catch (error) {
      throw Exception('Apple sign-in failed: $error');
    }
  }

  // Get user role from profile
  Future<String?> getUserRole() async {
    try {
      if (!isAuthenticated) return null;
      // Mock implementation - return default role
      return 'member';
    } catch (error) {
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

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      if (!isAuthenticated) throw Exception('No user logged in');
      
      // Mock implementation - just sign out
      await signOut();
    } catch (error) {
      throw Exception('Account deletion failed: $error');
    }
  }
}
