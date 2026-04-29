import 'package:flutter/foundation.dart';
import '../features/authentication/models/user_model.dart';

/// Repository for managing user data
/// Implements user registration, authentication, and profile management
class UserRepository {
  static final UserRepository _instance = UserRepository._internal();

  factory UserRepository() {
    return _instance;
  }

  UserRepository._internal();

  static UserRepository get instance => _instance;

  // Mock data storage
  final Map<String, UserModel> _users = {};
  UserModel? _currentUser;
  final List<ValueNotifier<UserModel?>> _listeners = [];

  // Initialize with sample users
  void initializeSampleData() {
    if (_users.isNotEmpty) return;

    final adminUser = UserModel.tambahData(
      idUser: 'admin_001',
      username: 'admin',
      password: 'admin123',
      email: 'admin@sportzones.com',
      role: 'admin',
      imgUrl: {
        'url': 'https://via.placeholder.com/150',
        'source': 'seed',
      },
    );

    final regularUser = UserModel.tambahData(
      idUser: 'user_001',
      username: 'hendrik',
      password: 'user123',
      email: 'hendriktimang@gmail.com',
      role: 'user',
      imgUrl: {
        'url': 'https://via.placeholder.com/150',
        'source': 'seed',
      },
    );

    _users[adminUser.idUser] = adminUser;
    _users[regularUser.idUser] = regularUser;
  }

  /// tambahData → Register new user
  bool tambahData({
    required String username,
    required String password,
    required String email,
  }) {
    // Check if username already exists
    if (_users.values.any((user) => user.username == username)) {
      return false;
    }

    final newUser = UserModel.tambahData(
      idUser: 'user_${_users.length + 1}',
      username: username,
      password: password,
      email: email,
    );

    _users[newUser.idUser] = newUser;
    return true;
  }

  /// ubahData → Update user profile
  bool ubahData({
    required String userId,
    String? username,
    String? email,
    String? imgUrl,
  }) {
    if (!_users.containsKey(userId)) {
      return false;
    }

    final updatedUser = _users[userId]!.ubahData(
      username: username,
      email: email,
      imgUrl: imgUrl == null
          ? null
          : {
              'url': imgUrl,
              'source': 'repository_update',
            },
    );

    _users[userId] = updatedUser;

    // Update current user if it's the logged-in user
    if (_currentUser?.idUser == userId) {
      _currentUser = updatedUser;
      _notifyListeners();
    }

    return true;
  }

  /// Login user
  bool login(String username, String password) {
    try {
      final user = _users.values.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      _currentUser = user;
      _notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  void logout() {
    _currentUser = null;
    _notifyListeners();
  }

  /// Get current logged-in user
  UserModel? getCurrentUser() => _currentUser;

  /// Set current user (used by Firebase authentication)
  void setCurrentUser(UserModel user) {
    _currentUser = user;
    if (!_users.containsKey(user.idUser)) {
      _users[user.idUser] = user;
    } else {
      _users[user.idUser] = user;
    }
    _notifyListeners();
  }

  /// Get user by ID
  UserModel? getUserById(String userId) => _users[userId];

  /// Get user by username
  UserModel? getUserByUsername(String username) {
    try {
      return _users.values.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  /// Add saved news to user
  void addSavedNews(String userId, String newsId) {
    if (_users.containsKey(userId)) {
      _users[userId] = _users[userId]!.addSavedNews(newsId);

      if (_currentUser?.idUser == userId) {
        _currentUser = _users[userId]!;
        _notifyListeners();
      }
    }
  }

  /// Remove saved news from user
  void removeSavedNews(String userId, String newsId) {
    if (_users.containsKey(userId)) {
      _users[userId] = _users[userId]!.removeSavedNews(newsId);

      if (_currentUser?.idUser == userId) {
        _currentUser = _users[userId]!;
        _notifyListeners();
      }
    }
  }

  /// Check if news is saved by user
  bool isNewsSaved(String userId, String newsId) {
    return _users[userId]?.isNewsSaved(newsId) ?? false;
  }

  /// Get all saved news IDs for user
  List<String> getSavedNews(String userId) {
    return _users[userId]?.savedNews ?? [];
  }

  /// Check if user is admin
  bool isUserAdmin(String userId) {
    final user = _users[userId];
    return user != null && user.role == 'admin';
  }

  /// Get all users (for admin purposes)
  List<UserModel> getAllUsers() => _users.values.toList();

  /// Get user count
  int getUserCount() => _users.length;

  /// Add listener for current user changes
  void addListener(VoidCallback listener) {
    final notifier = ValueNotifier<UserModel?>(_currentUser);
    notifier.addListener(listener);
    _listeners.add(notifier);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener.value = _currentUser;
    }
  }
}
