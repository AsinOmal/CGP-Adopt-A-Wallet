import 'package:cloud_firestore/cloud_firestore.dart';

class GroupExpense {
  String id;
  final String description;
  final double amount;
  final String paidBy; // userId
  final Map<String, double> splitMap; // {userId: amount}
  final Map<String, bool> repayments; // {userId: paid or not}
  final Timestamp createdAt;

  GroupExpense({
    String? id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitMap,
    required this.repayments,
    required this.createdAt,
  }) : id = id ?? '';

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'paidBy': paidBy,
        'splitMap': splitMap,
        'repayments': repayments,
        'createdAt': createdAt,
      };

  factory GroupExpense.fromJson(Map<String, dynamic> json) {
    return GroupExpense(
      id: json['id'] ?? '',
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'],
      splitMap: Map<String, double>.from(
        (json['splitMap'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      repayments: Map<String, bool>.from(json['repayments']),
      createdAt: json['createdAt'],
    );
  }
}