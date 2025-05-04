import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String id;
  final String userID;
  String title;
  String category;
  double amount;
  String date;
  final bool isIncome;
  final Timestamp createdAt;

  Transaction({
    String? id,
    required this.userID,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.createdAt,
  }) : id = id ?? '';

  toJson() => {
        'id': id,
        'userID': userID,
        'title': title,
        'category': category,
        'amount': amount,
        'date': date,
        'isIncome': isIncome,
        'createdAt': createdAt,
      };

  factory Transaction.fromJson(dynamic json) {
    return Transaction(
      id: json['id'],
      userID: json['userID'],
      title: json['title'],
      category: json['category'],
      amount: json['amount'],
      date: json['date'],
      isIncome: json['isIncome'],
      createdAt: json['createdAt'],
    );
  }
}
