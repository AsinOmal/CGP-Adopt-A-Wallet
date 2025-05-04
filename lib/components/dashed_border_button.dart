import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class DashedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  const DashedButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(15),
      strokeWidth: 1.5,
      color: Colors.grey,
      padding: EdgeInsets.zero, // Remove padding here
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15), // Match the border radius
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0, // Set minimum height to remove extra space
            backgroundColor:
                Theme.of(context).colorScheme.surface, // Button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.secondaryFixed,
              ), // Adjust icon color
              const SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondaryFixed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
