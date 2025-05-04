import 'package:firebase_auth/firebase_auth.dart' as auth;

class AuthResult {
  final auth.User? user;
  final String? message;

  AuthResult({
    this.user,
    this.message,
  });
}
