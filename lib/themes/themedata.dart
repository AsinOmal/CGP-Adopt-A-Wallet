import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  fontFamily: 'Poppins',
  brightness: Brightness.light,
  datePickerTheme: const DatePickerThemeData(
    headerBackgroundColor: Color(0xFF456EFE),
    headerForegroundColor: Colors.white,
    dividerColor: Color(0xFF456EFE),
  ),
  appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        color: Colors.black,
      )),
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    primary: Color(0xFF456EFE),
    surfaceDim: Color(0xFFf2f2f3),
    secondary: Colors.white,
    secondaryFixed: Colors.black,
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.grey[200]!,
  ),
);

ThemeData darkMode = ThemeData(
  fontFamily: 'Poppins',
  brightness: Brightness.dark,
  datePickerTheme: const DatePickerThemeData(
    headerForegroundColor: Colors.white,
    headerBackgroundColor: Color(0xFF456EFE),
    dividerColor: Color(0xFF456EFE),
  ),
  colorScheme: ColorScheme.dark(
    surface: const Color(0xFF111315),
    primary: const Color(0xFF456EFE),
    surfaceDim: const Color(0xFF292b2c),
    secondary: Colors.grey.shade800,
    secondaryFixed: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF111315),
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Colors.grey[900]!,
  ),
);

var feedbackThemeData = FeedbackThemeData(
  bottomSheetTextInputStyle: const TextStyle(
    color: Colors.white,
  ),
  bottomSheetDescriptionStyle: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
  feedbackSheetColor: const Color(0xFF111315),
  drawColors: [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ],
);
