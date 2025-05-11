import 'package:flutter/material.dart';

class SettleScreen extends StatelessWidget {
  final List<Map<String, dynamic>> expenses = [
    {
      'title': 'Groceries',
      'amount': 3000,
      'paidBy': 'Asin',
      'settles': [
        {'from': 'Jason', 'to': 'Asin', 'amount': 1500},
        {'from': 'Sarah', 'to': 'Asin', 'amount': 1500},
      ]
    },
    {
      'title': 'Electricity Bill',
      'amount': 1200,
      'paidBy': 'Sarah',
      'settles': [
        {'from': 'Asin', 'to': 'Sarah', 'amount': 600},
        {'from': 'Jason', 'to': 'Sarah', 'amount': 600},
      ]
    },
  ];

  SettleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settle Up'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
            return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                expense['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                ),
                const SizedBox(height: 8),
                Text(
                'Paid by ${expense['paidBy']} — Rs. ${expense['amount']}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                ),
                const Divider(
                height: 20,
                thickness: 1,
                color: Colors.grey,
                ),
                ...List.generate(expense['settles'].length, (settleIndex) {
                final settle = expense['settles'][settleIndex];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                    '${settle['from']} owes ${settle['to']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    ),
                    Text(
                    'Rs. ${settle['amount']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    ),
                  ],
                  ),
                );
                }),
              ],
              ),
            ),
            );
        },
      ),
    );
  }
}
