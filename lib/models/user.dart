import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userID;
  final String name;
  final String email;
  final String phoneNumber;
  final String gender;
  final String birthDate;
  final Timestamp createdAt;
  final String languagePreference;
  final String currencyPreference;
  final String profileImageURL;

  User({
    required this.userID,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.gender = '',
    this.birthDate = '',
    required this.createdAt,
    this.languagePreference = 'en',
    this.currencyPreference = 'LKR',
    this.profileImageURL = '',
  });

  toJson() => {
        'userID': userID,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'birthDate': birthDate,
        'createdAt': createdAt,
        'languagePreference': languagePreference,
        'currencyPreference': currencyPreference,
        'profileImageURL': profileImageURL,
      };

  factory User.fromJson(dynamic json) {
    return User(
      userID: json['userID'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      birthDate: json['birthDate'],
      createdAt: json['createdAt'],
      languagePreference: json['languagePreference'],
      currencyPreference: json['currencyPreference'],
      profileImageURL: json['profileImageURL'],
    );
  }
}
