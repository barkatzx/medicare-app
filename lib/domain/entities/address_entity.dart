class AddressEntity {
  final String id;
  final String userId;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressEntity({
    required this.id,
    required this.userId,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  AddressEntity copyWith({
    String? id,
    String? userId,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
