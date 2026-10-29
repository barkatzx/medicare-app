class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final String? photo;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    this.photo,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    final photoValue = json['photo']?.toString();
    return NotificationEntity(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      photo: photoValue == null || photoValue.isEmpty ? null : photoValue,
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
    id: id,
    title: title,
    message: message,
    photo: photo,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
