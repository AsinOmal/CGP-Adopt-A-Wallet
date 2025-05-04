import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  String id;
  final String userID;
  String category;
  double amount;
  double currentAmount;
  String timePeriod;
  final Timestamp createdAt;
  final Timestamp lastReset;

  Budget({
    String? id,
    required this.userID,
    required this.category,
    required this.amount,
    required this.currentAmount,
    required this.timePeriod,
    required this.createdAt,
    required this.lastReset,
  }) : id = id ?? '';

  toJson() => {
        'id': id,
        'userID': userID,
        'category': category,
        'amount': amount,
        'currentAmount': currentAmount,
        'timePeriod': timePeriod,
        'createdAt': createdAt,
        'lastReset': lastReset,
      };

  factory Budget.fromJson(dynamic json) {
    return Budget(
      id: json['id'],
      userID: json['userID'],
      category: json['category'],
      amount: json['amount'],
      currentAmount: json['currentAmount'],
      timePeriod: json['timePeriod'],
      createdAt: json['createdAt'],
      lastReset: json['lastReset'],
    );
  }
}
