import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/navigators/navigation_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conformPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Color emailBorderColor = Colors.transparent;
  Color nameBorderColor = Colors.transparent;
  Color passwordBorderColor = Colors.transparent;
  Color confirmPasswordBorderColor = Colors.transparent;

  late AuthBloc authBloc;

  @override
  void initState() {
    authBloc = RepositoryProvider.of<AuthBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    conformPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pop(context);
            showSuccessSnakBar();
            globalNavigatorKey.currentState!.pushReplacementNamed('/home');
          } else if (state is AuthError) {
            Navigator.pop(context);
            showErrorSnackBar(state.message);
          } else if (state is AuthLoading) {
            //show loading animation
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
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Header
                      Text(
                        AppLocalizations.of(context)
                            .translate('create_account'),
                        style: const TextStyle(
                          color: Color(0xFF446efe),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        textAlign: TextAlign.center,
                        AppLocalizations.of(context)
                            .translate('create_account_subtitle'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 80),
                      // Full Name field
                      InputField(
                        isReadOnly: false,
                        controller: nameController,
                        isObsecure: false,
                        label: AppLocalizations.of(context).translate('name'),
                        suffixIcon: null,
                        onChanged: (text) {
                          String formattedText = _capitalizeWords(text);
                          if (formattedText != text) {
                            nameController.value = TextEditingValue(
                              text: formattedText,
                              selection: TextSelection.collapsed(
                                  offset: formattedText.length),
                            );
                          }
                        },
                        borderColor: nameBorderColor,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 25),
                      // Email field
                      InputField(
                          isReadOnly: false,
                          controller: emailController,
                          isObsecure: false,
                          label:
                              AppLocalizations.of(context).translate('email'),
                          borderColor: emailBorderColor,
                          suffixIcon: null),
                      const SizedBox(height: 25),
                      // Password field

                      InputField(
                        isReadOnly: false,
                        controller: passwordController,
                        isObsecure: !_isPasswordVisible,
                        borderColor: passwordBorderColor,
                        label:
                            AppLocalizations.of(context).translate('password'),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Confirm Password field
                      InputField(
                        isReadOnly: false,
                        controller: conformPasswordController,
                        isObsecure: !_isConfirmPasswordVisible,
                        borderColor: confirmPasswordBorderColor,
                        label: AppLocalizations.of(context)
                            .translate('confirm_password'),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          icon: Icon(_isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      const SizedBox(height: 180),
                      // Sign Up button
                    ],
                  ),
                ),
              ),
              SimpleButton(
                data: AppLocalizations.of(context).translate('sign_up'),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  final email = emailController.text;
                  final name = nameController.text;
                  final password = passwordController.text;
                  final confirmPassword = conformPasswordController.text;

                  if (_validateInputs(email, name, password, confirmPassword)) {
                    authBloc.add(
                      AuthSignUpRequest(
                        name: name,
                        email: email,
                        password: password,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)
                        .translate('already_have_account'),
                  ),
                  TextButton(
                    onPressed: () {
                      globalNavigatorKey.currentState!
                          .pushReplacementNamed('/login');
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('login'),
                      style: const TextStyle(color: Color(0xFF456EFE)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs(
      String email, String name, String password, String confirmPassword) {
    setState(() {
      // Reset border colors
      emailBorderColor = Colors.transparent;
      nameBorderColor = Colors.transparent;
      passwordBorderColor = Colors.transparent;
      confirmPasswordBorderColor = Colors.transparent;
    });
    if (name.isEmpty) {
      setState(() {
        nameBorderColor = Colors.red;
      });
      showErrorSnackBar('A name is required to complete your sign-up.');
      return false;
    } else if (email.isEmpty) {
      setState(() {
        emailBorderColor = Colors.red;
      });
      showErrorSnackBar('An email address is required to continue.');
      return false;
    } else if (!isValidEmail(email)) {
      setState(() {
        emailBorderColor = Colors.red;
      });
      showErrorSnackBar(
          'Please enter a valid email address (e.g., example@domain.com).');
      return false;
    } else if (password.isEmpty) {
      setState(() {
        passwordBorderColor = Colors.red;
      });
      showErrorSnackBar('A password is required to continue.');
      return false;
    } else if (confirmPassword.isEmpty) {
      setState(() {
        confirmPasswordBorderColor = Colors.red;
      });
      showErrorSnackBar('A confirm password is required to continue.');
      return false;
    } else if (password != confirmPassword) {
      setState(() {
        confirmPasswordBorderColor = Colors.red;
      });
      showErrorSnackBar('Passwords didn\'t match.');
      return false;
    }

    return true;
  }

  bool isValidEmail(String email) {
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  void showErrorSnackBar(String error) {
    CustomSnackBar.show(
      context,
      title: 'On Snap!',
      message: error,
      contentType: ContentType.failure,
    );
  }

  String _capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: 'You\'re In!!',
      message: 'Your account has been created successfully.',
      contentType: ContentType.success,
    );
  }
}
