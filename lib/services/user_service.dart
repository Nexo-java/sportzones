/// Global user service to manage user role state across the entire app
/// This is a singleton service that persists user role during navigation
class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  static UserService get instance => _instance;

  // User role state
  bool _isAdmin = false;

  /// Get current user role
  bool get isAdmin => _isAdmin;

  /// Set user role (called after login)
  void setRole(bool isAdmin) {
    _isAdmin = isAdmin;
  }

  /// Reset user role (called on logout)
  void reset() {
    _isAdmin = false;
  }

  /// Get user type as string
  String get userType => _isAdmin ? 'Admin' : 'User';
}
