class LocationEntity {
  final String id;
  final String name;
  final String? bnName;

  const LocationEntity({required this.id, required this.name, this.bnName});

  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    final bn = json['bnName']?.toString();
    return LocationEntity(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      bnName: bn == null || bn.isEmpty ? null : bn,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'bnName': bnName};

  String get label => name;
}
