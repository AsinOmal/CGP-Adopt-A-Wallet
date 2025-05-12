part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthSignUpRequest extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthSignUpRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class AuthSignInRequest extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequest({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignOutRequest extends AuthEvent {}

class AuthChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class AuthInfoFetching extends AuthEvent {
  final String userID;
  const AuthInfoFetching({required this.userID});

  @override
  List<Object> get props => [userID];
}

class AuthUpdateUser extends AuthEvent {
  final User user;
  final bool isImageChange;
  final File? image;
  const AuthUpdateUser({
    required this.isImageChange,
    required this.user,
    required this.image,
  });

  @override
  List<Object> get props => [user];
}

class AuthSignInWithGoogle extends AuthEvent {}

class AuthProfileImageUpdate extends AuthEvent {
  final File image;
  final User user;
  const AuthProfileImageUpdate({required this.user, required this.image});

  @override
  List<Object> get props => [image, user];
}

class AuthFetchUserNames extends AuthEvent {
  final List<String> userIDs;
  const AuthFetchUserNames({required this.userIDs});

  @override
  List<Object> get props => [userIDs];
}
