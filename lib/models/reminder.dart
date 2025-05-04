import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String userID;
  String id;
  String title;
  String description;
  String date;
  String time;
  String frequancy;
  final Timestamp createdAt;

  Reminder({
    String? id,
    required this.userID,
    required this.createdAt,
    required this.date,
    required this.description,
    required this.frequancy,
    required this.time,
    required this.title,
  }) : id = id ?? '';

  toJson() => {
        'id': id,
        'userID': userID,
        'title': title,
        'description': description,
        'date': date,
        'time': time,
        'frequency': frequancy,
        'createdAt': createdAt,
      };

  factory Reminder.fromJson(dynamic json) {
    return Reminder(
      id: json['id'],
      userID: json['userID'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      time: json['time'],
      frequancy: json['frequency'],
      createdAt: json['createdAt'],
    );
  }
}
