class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final bool isApproved;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pharmacyName;
  final String? defaultAddressId;
  final List<dynamic> addresses;
  final List<dynamic> notifications;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.isApproved,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.pharmacyName,
    this.defaultAddressId,
    this.addresses = const [],
    this.notifications = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone_number'] ?? json['phone'],
      avatar: json['avatar'],
      isApproved: json['isApproved'] ?? false,
      role: json['role'] ?? 'customer',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      pharmacyName: json['pharmacy_name'],
      defaultAddressId: json['defaultAddressId'],
      addresses: json['addresses'] ?? [],
      notifications: json['notifications'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phone,
      'avatar': avatar,
      'isApproved': isApproved,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pharmacy_name': pharmacyName,
      'defaultAddressId': defaultAddressId,
      'addresses': addresses,
      'notifications': notifications,
    };
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? message;

  AuthResponse({required this.success, this.token, this.user, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
    );
  }
}
