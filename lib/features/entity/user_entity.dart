import 'location_entity.dart';

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
  final String? fullAddress;
  final LocationEntity? division;
  final LocationEntity? district;
  final LocationEntity? upazila;

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
    this.fullAddress,
    this.division,
    this.district,
    this.upazila,
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
      fullAddress: json['fullAddress'],
      division: _location(json['division']),
      district: _location(json['district']),
      upazila: _location(json['upazila']),
    );
  }

  static LocationEntity? _location(dynamic obj) {
    if (obj is Map<String, dynamic>) return LocationEntity.fromJson(obj);
    return null;
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
      'fullAddress': fullAddress,
      'divisionId': division?.id,
      'districtId': district?.id,
      'upazilaId': upazila?.id,
      'division': division?.toJson(),
      'district': district?.toJson(),
      'upazila': upazila?.toJson(),
    };
  }

  bool get hasAddress =>
      (fullAddress?.trim().isNotEmpty ?? false) &&
      division != null &&
      district != null &&
      upazila != null;

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
