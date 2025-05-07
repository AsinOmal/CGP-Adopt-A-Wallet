import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id;
  final String name;
  final List<String> memberIds;
  final String description;
  final Timestamp createdAt;

  Group({
    String? id,
    required this.name,
    required this.memberIds,
    required this.createdAt,
    this.description = 'Not provided',
  }) : id = id ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'memberIds': memberIds,
        'description': description,
        'createdAt': createdAt,
      };

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'],
      memberIds: List<String>.from(json['memberIds']),
      description: json['description'] ?? 'Not provided',
      createdAt: json['createdAt'],
    );
  }
}
