import '../../domain/entities/user_entity.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final String? token;
  final UserEntity? user;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle both response formats
    if (json.containsKey('data')) {
      final data = json['data'];
      return AuthResponseModel(
        success: true,
        message: data['message'] ?? json['message'] ?? '',
        token: data['token'],
        user: data['user'] != null ? UserEntity.fromJson(data['user']) : null,
      );
    } else {
      return AuthResponseModel(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        token: json['token'],
        user: json['user'] != null ? UserEntity.fromJson(json['user']) : null,
      );
    }
  }
}
