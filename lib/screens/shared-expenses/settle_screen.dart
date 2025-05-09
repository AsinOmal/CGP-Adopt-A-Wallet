import 'package:flutter/material.dart';

class SettleScreen extends StatelessWidget {
  const SettleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settle Up',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
    );
  }
}
