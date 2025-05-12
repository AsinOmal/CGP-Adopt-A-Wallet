import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/models/group_expense.dart';

class Group {
  String id;
  final String name;
  final List<String> memberIds;
  final String description;
  final Timestamp createdAt;
  final List<GroupExpense> expenses;

  Group({
    String? id,
    required this.name,
    required this.memberIds,
    required this.createdAt,
    this.expenses = const [],
    this.description = 'Not provided',
  }) : id = id ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'memberIds': memberIds,
        'description': description,
        'createdAt': createdAt,
        'expenses': expenses.map((e) => e.toJson()).toList(),
      };

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'],
      memberIds: List<String>.from(json['memberIds']),
      description: json['description'] ?? 'Not provided',
      createdAt: json['createdAt'],
      expenses: (json['expenses'] as List<dynamic>?)
          ?.map((e) => GroupExpense.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
