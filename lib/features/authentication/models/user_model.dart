/// User model for authentication
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profile_image': profileImage,
    };
  }
}
