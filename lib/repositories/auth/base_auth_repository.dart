import 'package:financial_app/models/user.dart';
import 'package:financial_app/repositories/auth/auth_result.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

abstract class BaseAuthRepository {
  Stream<auth.User?> get userStream;

  String get userID;

  auth.User? get currentUser;

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<AuthResult> signInWithGoogle();

  Future<void> updateUser(User user);

  Future<AuthResult> chnagePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<User?> fetchUserData(String userID);

  Future<void> addUserIfNotExists(User newUser);

  Future<Map<String, String>> fetchUserNames(List<String> userIDs);
}
