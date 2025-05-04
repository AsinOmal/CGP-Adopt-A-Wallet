import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  String id;
  final String userID;
  String title;
  double currentAmount;
  double targetAmount;
  String deadline;
  final Timestamp createdAt;

  Goal({
    String? id,
    required this.userID,
    required this.title,
    required this.currentAmount,
    required this.deadline,
    required this.createdAt,
    required this.targetAmount,
  }) : id = id ?? '';

  toJson() => {
        'id': id,
        'userID': userID,
        'title': title,
        'currentAmount': currentAmount,
        'targetAmount': targetAmount,
        'date': deadline,
        'createdAt': createdAt,
      };

  factory Goal.fromJson(dynamic json) {
    return Goal(
      id: json['id'],
      userID: json['userID'],
      title: json['title'],
      currentAmount: json['currentAmount'],
      targetAmount: json['targetAmount'],
      deadline: json['date'],
      createdAt: json['createdAt'],
    );
  }
}
