import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';
import 'package:financial_app/screens/auth/new_password_screen.dart';
import 'package:financial_app/services/email_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String otp; // Receive OTP as a parameter
  final String email; // Receive email as a parameter

  const OtpVerificationScreen(
      {super.key, required this.otp, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isOtpCorrect = true; // To track OTP correctness

  late String otp;

  @override
  void initState() {
    super.initState();
    otp = widget.otp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('Email OTP Verification'),
          style: const TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user,
                size: 100, color: Color(0xFF456EFE)),
            const SizedBox(height: 40),
            const Text("Enter OTP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            const Text("Please enter the OTP sent to your email address"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _otpTextField(index)),
            ),
            const SizedBox(height: 30),
            const Text("Didn't Receive OTP?"),
            TextButton(
              onPressed: () async {
                // Resend OTP logic
                String email = widget.email; // Get email from passed parameter
                otp = Email().generateOtp(); // Generate a new OTP
                await Email().sendOtpEmail(
                    email, otp); // Send the new OTP to the entered email

                CustomSnackBar.showSuccessSnackBar('OTP Resent!', context);
              },
              child: const Text("Resend OTP",
                  style: TextStyle(color: Color(0xFF456EFE))),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _otpTextField(int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: _isOtpCorrect ? Colors.green : Colors.red,
              width: 2.0,
            ),
          ),
          counterText: '',
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to the next field if it exists
            if (index < 3) {
              FocusScope.of(_focusNodes[index].context!)
                  .requestFocus(_focusNodes[index + 1]);
            } else {
              _focusNodes[index].unfocus(); // Hide the keyboard on the last box
            }
          } else if (value.isEmpty && index > 0) {
            // Move to the previous field if empty
            FocusScope.of(_focusNodes[index].context!)
                .requestFocus(_focusNodes[index - 1]);
          }

          // Check OTP once all fields are filled
          String enteredOtp = _otpControllers.map((e) => e.text).join();
          if (enteredOtp.length == 4) {
            if (enteredOtp == otp) {
              setState(() {
                _isOtpCorrect =
                    true; // OTP is correct, change border color to green
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
              );
            } else {
              setState(() {
                _isOtpCorrect =
                    false; // OTP is incorrect, change border color to red
              });
              CustomSnackBar.showErrorSnackBar('Incorrect OTP', context);
            }
          }
        },
      ),
    );
  }
}
