import 'package:financial_app/components/simple_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_app/blocs/shared_expense/shared_expense_bloc.dart';
import 'package:financial_app/models/group_expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SplitMode { equally, custom }

class AddExpenseScreen extends StatefulWidget {
  static const routeName = '/add-expense';

  final List<Map<String, dynamic>> membersDetails;
  final String groupId;

  const AddExpenseScreen({
    super.key,
    required this.membersDetails,
    required this.groupId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  late String selectedPayer;
  String selectedSplitMode = 'Equally';
  SplitMode splitMode = SplitMode.equally;
  late Map<String, bool> splitEqually = {};
  late Map<String, TextEditingController> customAmountControllers = {};
  late List<String> members = [];

  // Track both name and ID of payer
  late String payerName;
  late String payerId;

  late Map<String, bool> splitBetween = {};
  late Map<String, String> memberIdMap = {}; // Map from name to ID

  late SharedExpenseBloc _sharedExpenseBloc;

  @override
  void initState() {
    super.initState();
    // Initialize data based on membersDetails
    members = widget.membersDetails.map((m) => m['name'] as String).toList();
    _sharedExpenseBloc = RepositoryProvider.of<SharedExpenseBloc>(context);

    // Create a map from name to ID
    for (var member in widget.membersDetails) {
      memberIdMap[member['name']] = member['id'];
    }

    // Debug the entire member mapping
    print('Member ID Map: $memberIdMap');

    if (members.isNotEmpty) {
      payerName = members[0];
      payerId = memberIdMap[payerName] ?? '';
      selectedPayer = payerName;
      print('Initial payer set to: $payerName (ID: $payerId)');
    }

    // Initialize maps based on actual members
    for (var member in members) {
      splitEqually[member] = true;
      customAmountControllers[member] = TextEditingController();
      splitBetween[member] = true;
    }
  }

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
      body: BlocListener<SharedExpenseBloc, SharedExpenseState>(
        listener: (context, state) {
          if (state is SharedExpenseAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense added successfully!')));
            Navigator.of(context).pop();
            _sharedExpenseBloc
                .add(SharedExpensesFetchRequest(groupId: widget.groupId));
          } else if (state is SharedExpenseAddedLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          } else if (state is SharedExpenseAddedError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.errorMessage}')));
          }
        },
        child: SingleChildScrollView(
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
                  value: payerName,
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
                    if (val != null) {
                      setState(() {
                        payerName = val;
                        payerId = memberIdMap[payerName] ?? '';
                        print(
                            'Selected payer changed to: $payerName (ID: $payerId)');
                        // Dump the entire map for debugging
                        print('Available member IDs: $memberIdMap');
                      });
                    }
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
                        side: const BorderSide(color: Color(0xFF456EFE)),
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
                  onPressed: _addExpense,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addExpense() {
    // Validate inputs
    if (descriptionController.text.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    try {
      final double totalAmount = double.parse(amountController.text);
      final Map<String, double> splitMap = {};
      final Map<String, bool> repayments = {};

      // Use the already stored payerId instead of looking it up again
      if (payerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error: Could not identify the payer')));
        return;
      }

      if (splitMode == SplitMode.equally) {
        // Calculate equal split amounts
        final participatingMembers =
            members.where((m) => splitEqually[m] == true).toList();
        if (participatingMembers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Please select at least one member to split with')));
          return;
        }

        final double equalShare = totalAmount / participatingMembers.length;

        for (var member in widget.membersDetails) {
          final name = member['name'];
          final id = member['id'];

          if (splitEqually[name] == true) {
            splitMap[id] = equalShare;
            repayments[id] = id == payerId; // Payer has already paid
          }
        }
      } else {
        // Use custom amounts
        double totalCustomAmount = 0;

        for (var member in widget.membersDetails) {
          final name = member['name'];
          final id = member['id'];

          final String amountText = customAmountControllers[name]!.text;
          if (amountText.isNotEmpty) {
            final double amount = double.parse(amountText);
            totalCustomAmount += amount;
            splitMap[id] = amount;
            repayments[id] = id == payerId; // Payer has already paid
          }
        }

        // Validate total amount matches custom split
        if ((totalCustomAmount - totalAmount).abs() > 0.01) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Total of custom amounts must equal expense amount')));
          return;
        }
      }

      // Extra verification before creating expense
      print('Creating expense with:');
      print('- Description: ${descriptionController.text}');
      print('- Amount: $totalAmount');
      print('- Payer Name: $payerName');
      print('- Payer ID: $payerId');
      print('- Split Mode: $splitMode');

      if (payerId != memberIdMap[payerName]) {
        print(
            'ERROR: Payer ID mismatch! Expected ${memberIdMap[payerName]}, got $payerId');
      }

      // Create GroupExpense object with the correct payer ID
      final GroupExpense groupExpense = GroupExpense(
        description: descriptionController.text,
        amount: totalAmount,
        paidBy: payerId,
        splitMap: splitMap,
        repayments: repayments,
        createdAt: Timestamp.now(),
      );

      print('Adding expense with payer ID: $payerId'); // Debug info

      // Dispatch event to SharedExpenseBloc
      context.read<SharedExpenseBloc>().add(
            SharedExpenseAddExpenseRequest(
              groupExpense: groupExpense,
              groupId: widget.groupId,
            ),
          );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
