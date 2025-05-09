class GroupInvite {
  String id;
  final String groupId;
  final String userId;
  final bool isAccepted;
  final DateTime createdAt;

  GroupInvite({
    String? id,
    required this.groupId,
    required this.userId,
    required this.isAccepted,
    required this.createdAt,
  }) : id = id ?? '';

  factory GroupInvite.fromJson(Map<String, dynamic> json) {
    return GroupInvite(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      isAccepted: json['isAccepted'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'isAccepted': isAccepted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}