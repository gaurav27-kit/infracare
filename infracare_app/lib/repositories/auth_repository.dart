import '../models/user_model.dart';

/// Exception thrown when authentication fails.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Abstract contract for authentication data sources.
///
/// This interface ensures authentication logic is isolated from the UI,
/// allowing the mock repository to be replaced seamlessly by a REST API
/// repository or Campus OS authentication provider in future phases.
abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
}

/// Mock authentication repository for development and local testing.
class MockAuthRepository implements AuthRepository {
  static const Map<String, UserModel> _mockUsers = {
    'student@infracare.com': UserModel(
      id: 'usr_student_01',
      email: 'student@infracare.com',
      name: 'Student User',
      role: UserRole.student,
    ),
    'admin@infracare.com': UserModel(
      id: 'usr_admin_01',
      email: 'admin@infracare.com',
      name: 'Campus Administrator',
      role: UserRole.admin,
    ),
  };

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network latency for authenticating
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedEmail = email.trim().toLowerCase();

    if (!_mockUsers.containsKey(normalizedEmail)) {
      throw const AuthException(
        'Invalid credentials. Please use student@infracare.com or admin@infracare.com for development testing.',
      );
    }

    if (password.trim().isEmpty) {
      throw const AuthException('Password cannot be empty.');
    }

    return _mockUsers[normalizedEmail]!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
