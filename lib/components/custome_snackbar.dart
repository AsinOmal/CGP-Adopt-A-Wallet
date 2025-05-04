import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
    int durationSeconds = 3,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          duration: Duration(seconds: durationSeconds),
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: contentType,
          ),
        ),
      );
  }

  static showErrorSnackBar(String error, BuildContext context) {
    show(
      context,
      title: 'Oh Snap!',
      message: error,
      contentType: ContentType.failure,
    );
  }

  static showSuccessSnackBar(String success, BuildContext context) {
    show(
      context,
      title: 'Successful!',
      message: success,
      contentType: ContentType.success,
    );
  }
}
