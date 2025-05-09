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
  late String paidBy;
  late Map<String, bool> splitBetween = {};

  late SharedExpenseBloc _sharedExpenseBloc;

  @override
  void initState() {
    super.initState();
    // Initialize data based on membersDetails
    members = widget.membersDetails.map((m) => m['name'] as String).toList();
    _sharedExpenseBloc = RepositoryProvider.of<SharedExpenseBloc>(context);

    if (members.isNotEmpty) {
      paidBy = members[0];
      selectedPayer = paidBy;
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
            _sharedExpenseBloc.add(SharedExpensesFetchRequest(groupId: widget.groupId));
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

      // Get payer's ID from membersDetails
      String payerId = '';
      for (var member in widget.membersDetails) {
        if (member['name'] == paidBy) {
          payerId = member['id'];
          break;
        }
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

      // Create GroupExpense object
      final GroupExpense groupExpense = GroupExpense(
        description: descriptionController.text,
        amount: totalAmount,
        paidBy: payerId,
        splitMap: splitMap,
        repayments: repayments,
        createdAt: Timestamp.now(),
      );

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
