class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? avatar;
  final String role;
  final bool isApproved;
  final String? pharmacyName;
  final DateTime createdAt;
  final String? defaultAddressId;
  final List<dynamic> addresses;
  final List<dynamic> notifications;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.avatar,
    required this.role,
    required this.isApproved,
    this.pharmacyName,
    required this.createdAt,
    this.defaultAddressId,
    this.addresses = const [],
    this.notifications = const [],
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      avatar: json['avatar'],
      role: json['role'] ?? 'customer',
      isApproved: json['isApproved'] ?? false,
      pharmacyName: json['pharmacy_name'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
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
      'phone_number': phoneNumber,
      'avatar': avatar,
      'role': role,
      'isApproved': isApproved,
      'pharmacy_name': pharmacyName,
      'createdAt': createdAt.toIso8601String(),
      'defaultAddressId': defaultAddressId,
      'addresses': addresses,
      'notifications': notifications,
    };
  }

  bool get isCustomer => role.toLowerCase() == 'customer';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isPharmacy => role.toLowerCase() == 'pharmacy';

  String get approvalStatusMessage {
    if (isApproved) {
      return 'Account verified';
    } else {
      return 'Your account is pending approval. Please wait for admin approval.';
    }
  }
}
