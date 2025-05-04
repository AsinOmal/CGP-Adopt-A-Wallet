import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/services/email_service.dart';
import 'package:financial_app/screens/auth/otp_verification_screen.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String otp = ''; // Store OTP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ("Email Verification"),
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 100, color: Color(0xFF456EFE)),
            const SizedBox(height: 30),
            const Text("Email Verification",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("We need to send a verification code to your email"),
            const SizedBox(height: 50),
            InputField(
              isObsecure: false,
              controller: _emailController,
              isReadOnly: false,
              label: "Email Address",
              keyboardType: TextInputType.emailAddress,
            ),
            const Spacer(),
            SimpleButton(
              data: "Send Code",
              onPressed: () async {
                String email = _emailController.text;
                if (email.isNotEmpty) {
                  otp = Email().generateOtp(); // Generate OTP
                  await Email().sendOtpEmail(
                      email, otp); // Send OTP to the entered email

                  // Navigate to OTP verification screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OtpVerificationScreen(otp: otp, email: email),
                    ),
                  );
                } else {
                  // Show error if email is empty
                  CustomSnackBar.showErrorSnackBar(
                      'Please enter a valid email address', context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
