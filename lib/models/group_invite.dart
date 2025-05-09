class GroupInvite {
  String id;
  final String groupId;
  final String senderId;
  final String recipientId;
  final bool? isAccepted;
  final DateTime createdAt;

  GroupInvite({
    String? id,
    required this.groupId,
    required this.senderId,
    required this.recipientId,
    required this.isAccepted,
    required this.createdAt,
  }) : id = id ?? '';

  factory GroupInvite.fromJson(Map<String, dynamic> json) {
    return GroupInvite(
      id: json['id'],
      senderId: json['senderId'],
      groupId: json['groupId'],
      recipientId: json['recipientId'],
      isAccepted: json['isAccepted'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'recipientId': recipientId,
      'isAccepted': isAccepted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
