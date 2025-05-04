import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration; // Add duration parameter

  CustomPageRoute(
      {required this.page,
      this.duration =
          const Duration(milliseconds: 600)}) // Set a default duration
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration, // Set the transition duration
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from the right
            const end = Offset.zero; // End at the original position
            const curve = Curves.easeInToLinear;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
