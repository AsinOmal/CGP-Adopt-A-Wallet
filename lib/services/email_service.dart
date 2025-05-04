import 'dart:math';
import 'package:financial_app/data/keys.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'dart:developer' as dev;

class Email {
  String otp = ''; // Store OTP

  // Function to generate a random 4-digit OTP
  String generateOtp() {
    final random = Random();
    String otp = '';
    for (int i = 0; i < 4; i++) {
      // Generate 4-digit OTP
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  Future<void> sendOtpEmail(String email, String otp) async {
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = const Address(username, 'Adopt A Wallet')
      ..recipients.add(email)
      ..subject = 'Your OTP for Email Verification'
      ..text = '''
      Dear user,

      Your OTP is: $otp

      Please enter this OTP in the app to verify your email address.

      Best regards,
      Adopt A Wallet Team.
      ''';

    try {
      // Send the email
      final sendReport = await send(message, smtpServer);
      dev.log('Email sent: ${sendReport.toString()}');
    } on MailerException catch (e) {
      dev.log('Failed to send email: ${e.toString()}');
      for (var p in e.problems) {
        dev.log('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
