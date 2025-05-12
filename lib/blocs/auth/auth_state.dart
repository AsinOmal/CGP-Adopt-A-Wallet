part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthSuccess extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSignOut extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

final class AuthChangePasswordLoading extends AuthState {}

final class AuthChangePasswordSuccess extends AuthState {}

final class AuthChangePasswordError extends AuthState {
  final String message;

  const AuthChangePasswordError(this.message);

  @override
  List<Object> get props => [message];
}

final class AuthInfoLoading extends AuthState {}

final class AuthInfoSuccess extends AuthState {
  final User user;

  const AuthInfoSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

final class AuthInfoError extends AuthState {
  final String message;

  const AuthInfoError({required this.message});

  @override
  List<Object> get props => [message];
}

final class AuthUpdateLoading extends AuthState {}

final class AuthUpdateSuccess extends AuthState {}

final class AuthUpdateError extends AuthState {
  final String message;

  const AuthUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

final class AuthProfileImageUpdateSuccess extends AuthState {
  final String url;

  const AuthProfileImageUpdateSuccess({required this.url});

  @override
  List<Object> get props => [url];
}

final class AuthProfileImageUpdateError extends AuthState {
  final String message;

  const AuthProfileImageUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

// creates states for fetching user names
final class AuthUserNamesFetched extends AuthState {
  final Map<String, String> userNames;

  const AuthUserNamesFetched({required this.userNames});

  @override
  List<Object> get props => [userNames];
}

final class AuthUserNamesError extends AuthState {
  final String errorMessage;

  const AuthUserNamesError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

final class AuthUserNamesLoading extends AuthState {}

