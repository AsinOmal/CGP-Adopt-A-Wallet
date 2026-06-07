import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';

class ServicesIcon extends StatelessWidget {
  final Color? backgroundColor;
  final IconData? icon;
  final Color? foregroundColor;
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double iconDiameter;
  final double iconSize;
  final double labelFontSize;

  const ServicesIcon({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.foregroundColor,
    required this.text,
    required this.onPressed,
    this.width = 100,
    this.height = 100,
    this.iconDiameter = 60,
    this.iconSize = 40,
    this.labelFontSize = 12,
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
      width: width,
      height: height,
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            onPressed: onPressed,
            child: Container(
              width: iconDiameter,
              height: iconDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: foregroundColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).translate(text),
            style: TextStyle(
              fontSize: labelFontSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
