import 'package:financial_app/components/simple_button.dart';
import 'package:flutter/material.dart';

class AddGroupScreen extends StatelessWidget {
  static const routeName = '/create-shared-expense-group';
  AddGroupScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Shared Expense Group',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Group Name',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(23)),
                ),
                hintText: 'Enter group name',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description (optional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(23)),
                ),
                hintText: 'Enter short description',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Invite Friends or Family',
                style: TextStyle(fontWeight: FontWeight.w600)),
            //! meka kohomada hto karanne, existing users lata invite karanna hadanwada
            const SizedBox(height: 8),
            const SizedBox(height: 30),
            const Spacer(),
            SimpleButton(
              data: 'Create Group',
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
//onst Color(0xFF456EFE)
