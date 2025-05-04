import 'package:cloud_firestore/cloud_firestore.dart';

class Card {
  String id;
  final String userID;
  final String cardholderName;
  String cardNumber;
  String expireDate;
  String cvv;
  final bool isVisa;
  final Timestamp createdAt;

  Card({
    String? id,
    required this.userID,
    required this.cardholderName,
    required this.cardNumber,
    required this.expireDate,
    required this.cvv,
    required this.isVisa,
    required this.createdAt,
  }) : id = id ?? '';

  toJson() => {
        'id': id,
        'userID': userID,
        'cardholderName': cardholderName,
        'cardNumber': cardNumber,
        'expireDate': expireDate,
        'cvv': cvv,
        'isVisa': isVisa,
        'createdAt': createdAt,
      };

  factory Card.fromJson(dynamic json) {
    return Card(
      id: json['id'] ?? '',
      userID: json['userID'],
      cardholderName: json['cardholderName'],
      cardNumber: json['cardNumber'],
      expireDate: json['expireDate'],
      cvv: json['cvv'],
      isVisa: json['isVisa'],
      createdAt: json['createdAt'],
    );
  }
}
