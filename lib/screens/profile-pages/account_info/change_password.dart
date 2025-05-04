import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../components/input_field.dart';
import '../../../components/simple_button.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  Color currentPasswordBorder = Colors.transparent;
  Color newPasswordBorderColor = Colors.transparent;
  Color confirmPasswordBorderColor = Colors.transparent;
  final FocusNode newPasswordFocusNode = FocusNode();
  final FocusNode currentPasswordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = RepositoryProvider.of<AuthBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is AuthChangePasswordLoading ||
            current is AuthChangePasswordError ||
            current is AuthChangePasswordSuccess;
      },
      listener: (context, state) {
        if (state is AuthChangePasswordLoading) {
          showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: SpinKitThreeBounce(
                  color: Colors.white,
                  size: 50.0,
                ),
              );
            },
          );
        } else if (state is AuthChangePasswordSuccess) {
          Navigator.pop(context);
          clearFields();
          CustomSnackBar.showSuccessSnackBar(
              'Password change successfully', context);
        } else if (state is AuthChangePasswordError) {
          Navigator.pop(context);
          CustomSnackBar.showErrorSnackBar(state.message, context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('change_password'),
            style: const TextStyle(fontSize: 22),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              InputField(
                isReadOnly: false,
                controller: currentPasswordController,
                isObsecure: !_oldPasswordVisible,
                prefixIcon: Icons.lock,
                focusNode: currentPasswordFocusNode,
                borderColor: currentPasswordBorder,
                label: AppLocalizations.of(context).translate('old_password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _oldPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _oldPasswordVisible = !_oldPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              InputField(
                isReadOnly: false,
                controller: newPasswordController,
                isObsecure: !_newPasswordVisible,
                focusNode: newPasswordFocusNode,
                borderColor: newPasswordBorderColor,
                prefixIcon: Icons.lock,
                label: AppLocalizations.of(context).translate('new_password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _newPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _newPasswordVisible = !_newPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              InputField(
                isReadOnly: false,
                controller: confirmPasswordController,
                isObsecure: !_confirmPasswordVisible,
                focusNode: confirmPasswordFocusNode,
                borderColor: confirmPasswordBorderColor,
                prefixIcon: Icons.lock,
                label:
                    AppLocalizations.of(context).translate('confirm_password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
              const Spacer(),
              SimpleButton(
                data: 'change_password',
                onPressed: () {
                  currentPasswordFocusNode.unfocus();
                  newPasswordFocusNode.unfocus();
                  confirmPasswordFocusNode.unfocus();
                  FocusScope.of(context).unfocus();
                  String currentPassword = currentPasswordController.text;
                  String newPassword = newPasswordController.text;
                  String confirmPassword = confirmPasswordController.text;
                  if (_validateInputs(
                      currentPassword, newPassword, confirmPassword)) {
                    _authBloc.add(
                      AuthChangePasswordEvent(
                        currentPassword: currentPassword,
                        newPassword: newPassword,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs(
      String currentPassword, String newPassword, String confirmPassword) {
    setState(() {
      currentPasswordBorder = Colors.transparent;
      newPasswordBorderColor = Colors.transparent;
      confirmPasswordBorderColor = Colors.transparent;
    });
    if (currentPassword.isEmpty) {
      setState(() {
        currentPasswordBorder = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'Current password field empty!', context);
      return false;
    } else if (newPassword.isEmpty) {
      setState(() {
        newPasswordBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('New password field empty!', context);
      return false;
    } else if (confirmPassword.isEmpty) {
      setState(() {
        confirmPasswordBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'Confirm password field empty!', context);
      return false;
    } else if (newPassword != confirmPassword) {
      setState(() {
        newPasswordBorderColor = Colors.red;
        confirmPasswordBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'New password & confirm password didn\'t match!', context);
      return false;
    }
    return true;
  }

  void clearFields() {
    currentPasswordController.text = '';
    newPasswordController.text = '';
    confirmPasswordController.text = '';
  }
}
