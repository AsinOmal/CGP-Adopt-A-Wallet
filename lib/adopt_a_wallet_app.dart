import 'dart:async';
import 'dart:io';
import 'package:feedback/feedback.dart';
import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/blocs/budget/budget_bloc.dart';
import 'package:financial_app/blocs/card/card_bloc.dart';
import 'package:financial_app/blocs/goal/goal_bloc.dart';
import 'package:financial_app/blocs/reminder/reminder_bloc.dart';
import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/data/keys.dart';
import 'package:financial_app/language/language_provider.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/navigators/navigation_keys.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/repositories/budget/budget_repository.dart';
import 'package:financial_app/repositories/card/card_repository.dart';
import 'package:financial_app/repositories/goal/goal_repository.dart';
import 'package:financial_app/repositories/reminder/reminder_repository.dart';
import 'package:financial_app/repositories/transaction/transaction_repository.dart';
import 'package:financial_app/screens/auth/login_page.dart';
import 'package:financial_app/screens/auth/signup_page.dart';
import 'package:financial_app/screens/auth/forgot_password.dart';
import 'package:financial_app/screens/group-sharing/group_sharing_first_page.dart';
import 'package:financial_app/screens/home/home_page.dart';
import 'package:financial_app/screens/onboard/onboarding_page.dart';
import 'package:financial_app/screens/splash_screen/splash_screen.dart';
import 'package:financial_app/services/feedback_repository.dart';
import 'package:financial_app/services/secure_enctypted_key/key_manager.dart';
import 'package:financial_app/services/sms_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shake/shake.dart';
import 'package:financial_app/themes/themedata.dart';
import 'package:financial_app/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class AdoptAWalletApp extends StatefulWidget {
  const AdoptAWalletApp({super.key});

  @override
  State<AdoptAWalletApp> createState() => _AdoptAWalletAppState();
}

class _AdoptAWalletAppState extends State<AdoptAWalletApp>
    with WidgetsBindingObserver {
  late ShakeDetector shakeDetector;
  bool _hasCheckedAuthState = false;
  User? currentUser;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseAuth.instance.currentUser?.reload();
    if (!_hasCheckedAuthState) {
      _hasCheckedAuthState = true; // Prevent future invocations
      FirebaseAuth.instance.authStateChanges().first.then((user) {
        currentUser = user;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _routeUserForAuth(user);
        });
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    Provider.of<ThemeProvider>(context, listen: false)
        .updateThemeBasedOnSystem(brightness);
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    shakeDetector.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var authRepository = AuthRepository();
    var transactionRepository = TransactionRepository();
    var goalRepository = GoalRepository();
    var reminderRepository = ReminderRepository();
    var budgetRepository = BudgetRepository();
    var cardRepository = CardRepository();
    var transactionBloc = TransactionBloc(transactionRepository);

    var smsService = SmsService(
      transactionBloc: transactionBloc,
      authRepository: authRepository,
    );
    shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () {
        BetterFeedback.of(context).show((UserFeedback feedback) async {
          BetterFeedback.of(context).hide();
          try {
            final screenshotFilePath =
                await writeImageToStorage(feedback.screenshot);

            final smtpServer = gmail(username, password);

            final message = Message()
              ..from = const Address(username, 'Adopt A Wallet')
              ..recipients.add('adoptawallet.devnet.error@gmail.com')
              ..subject = 'App Feedback'
              ..text = feedback.text
              ..attachments = [FileAttachment(File(screenshotFilePath))];

            final sendReport = await send(message, smtpServer);
            dev.log('Feedback Email sent: ${sendReport.toString()}');
          } on MailerException catch (e) {
            dev.log('Failed to send feedback email: ${e.toString()}');
            for (var p in e.problems) {
              dev.log('Problem: ${p.code}: ${p.msg}');
            }
          }
        });
      },
      minimumShakeCount: 2,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    var app = MaterialApp(
      home: const GroupSharingFirst(),
      navigatorKey: globalNavigatorKey,
      debugShowCheckedModeBanner: false,
      //onGenerateRoute: getPageRouteSettings(),
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeProvider.themeMode,
      locale: languageProvider.locale,
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('sl', ''), // Sinhala
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
    FlutterNativeSplash.remove();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => authRepository,
        ),
        RepositoryProvider(
          create: (context) => transactionRepository,
        ),
        RepositoryProvider(
          create: (context) => goalRepository,
        ),
        RepositoryProvider(
          create: (context) => reminderRepository,
        ),
        RepositoryProvider(
          create: (context) => budgetRepository,
        ),
        RepositoryProvider(
          create: (context) => cardRepository,
        ),
        RepositoryProvider(
          create: (context) => AuthBloc(authRepository),
        ),
        RepositoryProvider(
          create: (context) => transactionBloc,
        ),
        RepositoryProvider(
          create: (context) => GoalBloc(goalRepository),
        ),
        RepositoryProvider(
          create: (context) => ReminderBloc(reminderRepository),
        ),
        RepositoryProvider(
          create: (context) => BudgetBloc(budgetRepository),
        ),
        RepositoryProvider(
          create: (context) => CardBloc(cardRepository),
        ),
        Provider(create: (context) => smsService),
      ],
      child: app,
    );
  }

  MaterialPageRoute Function(RouteSettings settings) getPageRouteSettings() {
    return (RouteSettings settings) {
      return MaterialPageRoute(
        builder: (context) => _getPageRoutes(context, settings),
      );
    };
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
  }

  _getPageRoutes(BuildContext context, RouteSettings settings) {
    dev.log('Navigating to: ${settings.name}');
    switch (settings.name) {
      case '/onboarding':
        return const OnboardingPage();
      case '/login':
        return const LoginScreen();
      case '/signup':
        return const SignupScreen();
      case '/forgot_password':
        return const ForgotPasswordPage();
      case '/home':
        return const HomePage();
      default:
        return const SplashScreen();
    }
  }

  static void _routeUserForAuth(User? user) async {
    await Future.delayed(const Duration(seconds: 2));
    bool isFirstRun = await IsFirstRun.isFirstCall();
    if (isFirstRun) {
      final keyManager = KeyManager();
      await keyManager.generateAndStoreKey();
      globalNavigatorKey.currentState!.pushReplacementNamed('/onboarding');
    } else {
      if (user != null) {
        globalNavigatorKey.currentState!.pushReplacementNamed('/home');
      } else {
        globalNavigatorKey.currentState!.pushReplacementNamed('/login');
      }
    }
  }
}
