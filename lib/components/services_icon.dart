import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';

class ServicesIcon extends StatelessWidget {
  final Color? backgroundColor;
  final IconData? icon;
  final Color? foregroundColor;
  final String text;
  final VoidCallback onPressed;

  const ServicesIcon({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.foregroundColor,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      width: 100,
      height: 100,
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              elevation: 0,
              padding:
                  EdgeInsets.zero, // Remove default padding from the button
            ),
            onPressed: onPressed,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(10.0), // Add padding around the icon
                child: Icon(
                  icon,
                  size: 40,
                  color: foregroundColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).translate(text),
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
