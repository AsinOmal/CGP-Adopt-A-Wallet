import 'package:flutter/material.dart';

class GroupSharingFirst extends StatelessWidget {
  const GroupSharingFirst({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text(
          "Group Budget Sharing",
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Text("Your Groups"),
          FloatingActionButton(
            child: const Icon(
              Icons.add,
              size: 30,
              weight: 5,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
