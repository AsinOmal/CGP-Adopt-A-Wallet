import 'package:flutter/material.dart';

class GlassEffectIcon extends StatelessWidget {
  final IconData? icon;
  const GlassEffectIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        padding: const EdgeInsets.all(3),
        child: Icon(
          icon,
          color: Colors.white,
          size: 13,
        ),
      ),
    );
  }
}
