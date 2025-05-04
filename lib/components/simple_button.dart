import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';

class SimpleButton extends StatelessWidget {
  final String data;
  final Function()? onPressed;
  final Color color;
  final Color textColor;
  const SimpleButton({
    super.key,
    required this.data,
    required this.onPressed,
    this.color = const Color(0xFF456EFE),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 13),
        backgroundColor: color,
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            AppLocalizations.of(context).translate(data),
            style: TextStyle(
              color: textColor,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
