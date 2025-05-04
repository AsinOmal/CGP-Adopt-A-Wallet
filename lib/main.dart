import 'package:feedback/feedback.dart';
import 'package:financial_app/adopt_a_wallet_app.dart';
import 'package:financial_app/language/language_provider.dart';
import 'package:financial_app/services/notification_service.dart';
import 'package:financial_app/themes/themedata.dart';
import 'package:financial_app/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
      url: 'https://wlujgctqyxyyegjttlce.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsdWpnY3RxeXh5eWVnanR0bGNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYyMzA3MzAsImV4cCI6MjA1MTgwNjczMH0.3D-9SXYh99R3HFisyPQCtJivXOhEKwTmVHXN8JdakXc');
  tz.initializeTimeZones();
  await NotificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: OverlaySupport.global(
        child: BetterFeedback(
          theme: feedbackThemeData,
          child: const AdoptAWalletApp(),
        ),
      ),
    ),
  );
}
