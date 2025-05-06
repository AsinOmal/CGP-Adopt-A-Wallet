import 'package:financial_app/screens/shared-expenses/add_expense_screen.dart';
import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatelessWidget {
  static const routeName = '/group-details';

  final List<String> members = ['Asin', 'Sarah', 'Jason'];
  final List<Map<String, dynamic>> expenses = [
    {'title': 'Groceries', 'amount': 3000, 'payer': 'Asin'},
    {'title': 'Electricity Bill', 'amount': 1200, 'payer': 'Sarah'},
  ];
  final List<Map<String, dynamic>> balances = [
    {'from': 'Jason', 'to': 'Asin', 'amount': 1500},
    {'from': 'Sarah', 'to': 'Jason', 'amount': 600},
  ];

  GroupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '{Group Name}',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Members',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: members
                  .map((m) => Chip(
                        label: Text(
                          m,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        elevation: 5,
                        backgroundColor: const Color(0xFF456EFE),
                        avatar: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            m[0],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              color: Colors.transparent,
                            )),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _button(context, 'Invite'),
                  const SizedBox(width: 8),
                  _button(context, 'Add Expense'),
                  const SizedBox(width: 8),
                  _button(context, 'Settle',
                      icon: Icons.construction), // Replace icon if needed
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Expenses',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ...expenses.map((e) => _expenseItem(e)),
            const Divider(height: 40),
            const Text('Remaining Balances',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ...balances.map((b) => _balanceItem(b)),
          ],
        ),
      ),
    );
  }

  Widget _button(BuildContext context, String label, {IconData? icon}) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return AddExpenseScreen();
          },
        ));
      },
      icon: icon != null ? Icon(icon) : const Icon(Icons.add),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _expenseItem(Map<String, dynamic> e) {
    return ListTile(
      title:
          Text(e['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
      leading: const Icon(Icons.monetization_on),
      subtitle: Text('Paid by ${e['payer']}',
          style:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
      trailing: Text('Rs. ${e['amount']}'),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _balanceItem(Map<String, dynamic> b) {
    return ListTile(
      leading: const Icon(Icons.swap_horiz),
      title: Text('${b['from']} owes ${b['to']}'),
      trailing: Text('Rs. ${b['amount']}'),
      contentPadding: EdgeInsets.zero,
    );
  }
}
