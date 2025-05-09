import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/blocs/shared_expense/shared_expense_bloc.dart';
import 'package:financial_app/models/group.dart';
import 'package:financial_app/models/group_expense.dart';
import 'package:financial_app/screens/shared-expenses/add_expense_screen.dart';
import 'package:financial_app/screens/shared-expenses/invite_members.dart';
import 'package:financial_app/screens/shared-expenses/settle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupDetailsScreen extends StatefulWidget {
  static const routeName = '/group-details';

  final Group group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final List<String> members = [];

  // create list of object of each members with their name and id
  final List<Map<String, dynamic>> membersDetails = [];

  // Update to use GroupExpense objects instead of Map
  List<GroupExpense> expenses = [];

  final List<Map<String, dynamic>> balances = [
    {'from': 'Jason', 'to': 'Asin', 'amount': 1500},
    {'from': 'Sarah', 'to': 'Jason', 'amount': 600},
  ];

  late AuthBloc _authBloc;
  late SharedExpenseBloc _sharedExpenseBloc;

  @override
  void initState() {
    _authBloc = RepositoryProvider.of<AuthBloc>(context);
    _sharedExpenseBloc = RepositoryProvider.of<SharedExpenseBloc>(context);

    // Fetch user names
    _authBloc.add(AuthFetchUserNames(userIDs: widget.group.memberIds));

    // Fetch group expenses
    _sharedExpenseBloc
        .add(SharedExpensesFetchRequest(groupId: widget.group.id));

    _authBloc.stream.listen((state) {
      if (state is AuthUserNamesFetched) {
        setState(() {
          members.clear();
          members.addAll(state.userNames);
        });
        // Create a list of members with their names and ids
        membersDetails.clear();
        for (int i = 0; i < widget.group.memberIds.length; i++) {
          membersDetails.add({
            'name': state.userNames[i],
            'id': widget.group.memberIds[i],
          });
        }
      }
    });

    // Listen to shared expense bloc states
    _sharedExpenseBloc.stream.listen((state) {
      if (state is SharedExpenseFetched) {
        setState(() {
          expenses = state.groupExpenses;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          group.name,
          style: const TextStyle(fontSize: 20),
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
                  _buttonInvite(context, 'Invite', groupId: group.id),
                  const SizedBox(width: 8),
                  _buttonAddExpense(context, 'Add Expense'),
                  const SizedBox(width: 8),
                  _buttonSettleScreen(context, 'Settle',
                      icon: Icons.construction), // Replace icon if needed
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Expenses',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            BlocBuilder<SharedExpenseBloc, SharedExpenseState>(
              buildWhen: (previous, current) =>
                  current is SharedExpenseFetchSharedExpensesLoading ||
                  current is SharedExpenseFetched ||
                  current is SharedExpenseFetchSharedExpensesError,
              builder: (context, state) {
                if (state is SharedExpenseFetchSharedExpensesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SharedExpenseFetched) {
                  expenses = state.groupExpenses;
                  if (expenses.isEmpty) {
                    return const Text('No expenses yet');
                  }
                  return Column(
                    children: expenses.map((e) => _expenseItem(e)).toList(),
                  );
                } else if (state is SharedExpenseFetchSharedExpensesError) {
                  return Text('Error: ${state.errorMessage}');
                } else {
                  return const Text('No expenses yet');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonInvite(BuildContext context, String label,
      {IconData? icon, required String groupId}) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return InviteMemberScreen(
              groupId: groupId,
            );
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

  Widget _buttonAddExpense(
    BuildContext context,
    String label, {
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return AddExpenseScreen(
              membersDetails: membersDetails,
              groupId: widget.group.id,
            );
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

  Widget _buttonSettleScreen(BuildContext context, String label,
      {IconData? icon}) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return const SettleScreen();
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

  // Update the expense item widget to use GroupExpense instead of Map
  Widget _expenseItem(GroupExpense expense) {
    // Find the name of the person who paid
    String payerName = 'Unknown';
    for (var member in membersDetails) {
      if (member['id'] == expense.paidBy) {
        payerName = member['name'];
        break;
      }
    }

    return ListTile(
      title: Text(expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      leading: const Icon(Icons.monetization_on),
      subtitle: Text('Paid by $payerName',
          style:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
      trailing: Text('Rs. ${expense.amount.toStringAsFixed(2)}'),
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
