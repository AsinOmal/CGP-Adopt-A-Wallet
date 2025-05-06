import 'package:financial_app/components/simple_button.dart';
import 'package:flutter/material.dart';

enum SplitMode { equally, custom }

class AddExpenseScreen extends StatefulWidget {
  static const routeName = '/add-expense';

  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  String selectedPayer = 'Asin';
  String selectedSplitMode = 'Equally';
  SplitMode splitMode = SplitMode.equally;
  final Map<String, bool> splitEqually = {
    'Asin': true,
    'Sarah': true,
    'Jason': true,
  };
  final Map<String, TextEditingController> customAmountControllers = {
    'Asin': TextEditingController(),
    'Sarah': TextEditingController(),
    'Jason': TextEditingController(),
  };
  final List<String> members = ['Asin', 'Sarah', 'Jason'];
  String paidBy = 'Asin';
  Map<String, bool> splitBetween = {
    'Asin': false,
    'Sarah': true,
    'Jason': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF456EFE),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Expense Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: paidBy,
                decoration: const InputDecoration(
                  labelText: 'Paid By',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                items: members.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    paidBy = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Split Between'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Color(0xFF456EFE)),
                    ),
                    label: const Text(
                      'Split Equally',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    selected: splitMode == SplitMode.equally,
                    onSelected: (_) {
                      setState(() => splitMode = SplitMode.equally);
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: const Color(0xFF456EFE)),
                    ),
                    label: const Text(
                      'Custom',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    selected: splitMode == SplitMode.custom,
                    onSelected: (_) {
                      setState(() => splitMode = SplitMode.custom);
                    },
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: members.map((m) {
                    return splitMode == SplitMode.equally
                        ? CheckboxListTile(
                            title: Text(m),
                            value: splitEqually[m],
                            onChanged: (val) {
                              setState(() {
                                splitEqually[m] = val!;
                              });
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextField(
                              controller: customAmountControllers[m],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '$m\'s Share',
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                              ),
                            ),
                          );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              SimpleButton(
                data: 'Add Expense',
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
