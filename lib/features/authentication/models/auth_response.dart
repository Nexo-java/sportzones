/// Authentication response model
class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final Map<String, dynamic>? user;

  AuthResponse({required this.success, this.message, this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> map) {
    return AuthResponse(
      success: map['success'] ?? false,
      message: map['message'],
      token: map['token'],
      user: map['user'],
    );
  }
}
