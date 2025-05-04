import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/navigators/navigation_keys.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/screens/auth/forgot_password.dart';
import 'package:financial_app/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Color emailBorderColor = Colors.transparent;
  Color passwordBorderColor = Colors.transparent;
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  late AuthBloc authBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStatusBar();
  }

  // Helper method to update the status bar based on theme mode
  void _updateStatusBar() {
    final themeMode = Provider.of<ThemeProvider>(context).themeMode;
    final brightness =
        themeMode == ThemeMode.dark ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness,
    ));
  }

  @override
  void initState() {
    authBloc = RepositoryProvider.of<AuthBloc>(context);
    super.initState();
  }

  void showErrorSnackBar(String error) {
    CustomSnackBar.show(context,
        title: 'On Snap!', message: error, contentType: ContentType.failure);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pop(context); // Pop the loading animation
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
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Text(
                  AppLocalizations.of(context).translate('login_account'),
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF446efe)),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context).translate('welcome_back'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 50),
                const SizedBox(height: 20),
                InputField(
                  isReadOnly: false,
                  isObsecure: false,
                  label: AppLocalizations.of(context).translate('email'),
                  suffixIcon: null,
                  focusNode: emailFocusNode,
                  controller: emailController,
                  borderColor: emailBorderColor,
                ),
                const SizedBox(height: 20),
                InputField(
                  isReadOnly: false,
                  controller: passwordController,
                  isObsecure: !_isPasswordVisible,
                  focusNode: passwordFocusNode,
                  borderColor: passwordBorderColor,
                  label: AppLocalizations.of(context).translate('password'),
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text(AppLocalizations.of(context)
                            .translate('remember_me')),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('forgot_password'),
                        style: const TextStyle(color: Color(0xFF446efe)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                SimpleButton(
                  data: AppLocalizations.of(context).translate('login'),
                  onPressed: () {
                    emailFocusNode.unfocus();
                    passwordFocusNode.unfocus();
                    FocusScope.of(context).unfocus();
                    final email = emailController.text;
                    final password = passwordController.text;
                    if (_validateInputs(email, password)) {
                      authBloc.add(
                          AuthSignInRequest(email: email, password: password));
                    }
                  },
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context).translate('no_account')),
                    TextButton(
                      onPressed: () {
                        globalNavigatorKey.currentState!
                            .pushReplacementNamed('/signup');
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('sign_up'),
                        style: const TextStyle(color: Color(0xFF446efe)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(AppLocalizations.of(context)
                          .translate('or_sign_up_with')),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        authBloc.add(AuthSignInWithGoogle());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).colorScheme.surfaceDim,
                        ),
                        child: Image.asset(
                          'assets/images/google.png',
                          height: 25,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateInputs(String email, String password) {
    setState(() {
      emailBorderColor = Colors.transparent;
      passwordBorderColor = Colors.transparent;
    });
    if (email.isEmpty) {
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
    }
    return true;
  }

  bool isValidEmail(String email) {
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }
}
