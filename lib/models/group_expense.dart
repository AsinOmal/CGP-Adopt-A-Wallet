import 'package:cloud_firestore/cloud_firestore.dart';

class GroupExpense {
  final String description;
  final double amount;
  final String paidBy; // userId
  final Map<String, double> splitMap; // {userId: amount}
  final Map<String, bool> repayments; // {userId: paid or not}
  final Timestamp createdAt;

  GroupExpense({
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitMap,
    required this.repayments,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
        'paidBy': paidBy,
        'splitMap': splitMap,
        'repayments': repayments,
        'createdAt': createdAt,
      };

  factory GroupExpense.fromJson(Map<String, dynamic> json) {
    try {
      Timestamp timestampValue;
      if (json['createdAt'] is Timestamp) {
        timestampValue = json['createdAt'];
      } else if (json['createdAt'] is Map) {
        final Map<String, dynamic> timestamp =
            json['createdAt'] as Map<String, dynamic>;
        timestampValue = Timestamp(
          timestamp['_seconds'] as int,
          timestamp['_nanoseconds'] as int,
        );
      } else {
        timestampValue = Timestamp.now();
      }

      // Handle splitMap more safely
      Map<String, double> splitMapConverted = {};
      if (json['splitMap'] is Map) {
        (json['splitMap'] as Map).forEach((key, value) {
          if (value is num) {
            splitMapConverted[key.toString()] = value.toDouble();
          } else if (value is String && double.tryParse(value) != null) {
            splitMapConverted[key.toString()] = double.parse(value);
          } else {
            splitMapConverted[key.toString()] = 0.0;
          }
        });
      }

      // Handle repayments more safely
      Map<String, bool> repaymentsConverted = {};
      if (json['repayments'] is Map) {
        (json['repayments'] as Map).forEach((key, value) {
          if (value is bool) {
            repaymentsConverted[key.toString()] = value;
          } else if (value is num) {
            repaymentsConverted[key.toString()] = value != 0;
          } else if (value is String) {
            repaymentsConverted[key.toString()] = value.toLowerCase() == 'true';
          } else {
            repaymentsConverted[key.toString()] = false;
          }
        });
      }

      return GroupExpense(
        description: json['description']?.toString() ?? '',
        amount:
            (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
        paidBy: json['paidBy']?.toString() ?? '',
        splitMap: splitMapConverted,
        repayments: repaymentsConverted,
        createdAt: timestampValue,
      );
    } catch (e) {
      return GroupExpense(
        description: json['description']?.toString() ?? 'Error',
        amount: 0.0,
        paidBy: '',
        splitMap: {},
        repayments: {},
        createdAt: Timestamp.now(),
      );
    }
  }
}
