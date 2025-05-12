import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_app/models/user.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'dart:developer' as developer;
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is AuthSignUpRequest) {
        emit(AuthLoading());
        final result = await _authRepository.signUp(
          email: event.email,
          password: event.password,
          name: event.name,
        );
        if (result.user != null) {
          emit(AuthSuccess());
          developer.log('Signup success');
        } else {
          emit(AuthError(result.message ?? 'Signup Failed'));
        }
      }

      if (event is AuthSignInRequest) {
        emit(AuthLoading());
        final result = await _authRepository.signIn(
            email: event.email, password: event.password);

        if (result.user != null) {
          emit(AuthSuccess());
        } else {
          emit(AuthError(result.message ?? 'Sign In Failed'));
        }
      }

      if (event is AuthSignOutRequest) {
        emit(AuthLoading());
        await _authRepository.signOut();
        await Future.delayed(const Duration(seconds: 1));
        emit(AuthSignOut());
        developer.log('Logging out');
      }

      if (event is AuthChangePasswordEvent) {
        emit(AuthChangePasswordLoading());
        final result = await _authRepository.chnagePassword(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        );
        if (result.message == 'success') {
          emit(AuthChangePasswordSuccess());
        } else {
          emit(AuthChangePasswordError(
              result.message ?? 'Password change Error!'));
        }
      }
      if (event is AuthInfoFetching) {
        try {
          emit(AuthInfoLoading());
          final user = await _authRepository.fetchUserData(event.userID);
          if (user != null) {
            emit(AuthInfoSuccess(user: user));
            emit(AuthProfileImageUpdateSuccess(url: user.profileImageURL));
          } else {
            emit(const AuthInfoError(message: 'Error while getting user data'));
          }
        } catch (e) {
          emit(const AuthInfoError(message: 'Error while getting user data'));
        }
      }
      if (event is AuthUpdateUser) {
        try {
          emit(AuthUpdateLoading());
          User user = event.user;
          if (event.image != null) {
            String url = await _authRepository.uploadImage(
                user: event.user, image: event.image!);
            emit(AuthProfileImageUpdateSuccess(url: url));
            await _authRepository.updateUser(
              User(
                userID: user.userID,
                name: user.name,
                email: user.email,
                createdAt: user.createdAt,
                phoneNumber: user.phoneNumber,
                gender: user.gender,
                birthDate: user.birthDate,
                profileImageURL: url,
                languagePreference: user.languagePreference,
                currencyPreference: user.currencyPreference,
              ),
            );
          } else {
            await _authRepository.updateUser(event.user);
          }
          emit(AuthUpdateSuccess());
        } catch (e) {
          emit(const AuthUpdateError(message: 'Error while updating user'));
        }
      }
      if (event is AuthSignInWithGoogle) {
        try {
          emit(AuthLoading());
          final result = await _authRepository.signInWithGoogle();
          if (result.user != null) {
            emit(AuthSuccess());
            developer.log('Signup success');
          } else {
            emit(AuthError(result.message ?? 'Signup Failed'));
          }
        } catch (e) {
          emit(const AuthError('Sign In Failed'));
        }
      }
      if(event is AuthFetchUserNames) {
        try {
          emit(AuthUserNamesLoading());
          final names = await _authRepository.fetchUserNames(event.userIDs);
          emit(AuthUserNamesFetched(userNames: names));
        } catch (e) {
          emit(const AuthUserNamesError( errorMessage: 'Error while fetching user names'));
        }
      }
    });
  }
}
