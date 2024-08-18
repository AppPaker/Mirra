class NotificationModel {
  String id;
  String? title;
  String? body;
  String? receiverId;
  DateTime timestamp;
  bool read;
  String senderId;
  String senderName;
  String inviteStatus;

  final String type;

  NotificationModel({
    required this.id,
    this.title,
    this.body,
    this.receiverId,
    required this.timestamp,
    this.read = false,
    required this.senderId,
    required this.senderName,
    this.inviteStatus = 'New',
    this.type = 'general',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receiverId': receiverId,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'senderId': senderId,
      'senderName': senderName,
      'inviteStatus': inviteStatus,
      'type': type,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      receiverId: json['receiverId'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      read: json['read'] ?? false,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      inviteStatus: json['inviteStatus'] ?? 'New',
      type: json['type'] ?? 'general',
    );
  }

  void toggleRead() {
    read = !read;
  }
}
