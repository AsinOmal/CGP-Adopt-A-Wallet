import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/blocs/shared_expense/shared_expense_bloc.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettleScreen extends StatefulWidget {
  final String groupId;

  const SettleScreen({super.key, required this.groupId});

  @override
  State<SettleScreen> createState() => _SettleScreenState();
}

class _SettleScreenState extends State<SettleScreen> {
  late SharedExpenseBloc _sharedExpenseBloc;
  late AuthRepository _authRepository;
  late AuthBloc _authBloc;

  Map<String, String> _userNames = {};
  bool _loadingUserNames = false;
  bool _usernameFetchFailed = false;

  @override
  void initState() {
    _sharedExpenseBloc = RepositoryProvider.of<SharedExpenseBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _sharedExpenseBloc.add(SharedExpensesFetchRequest(groupId: widget.groupId));
    _authBloc = RepositoryProvider.of<AuthBloc>(context);

    // Listen to AuthBloc state changes
    _authBloc.stream.listen((state) {
      if (state is AuthUserNamesLoading) {
        setState(() {
          _loadingUserNames = true;
        });
      } else if (state is AuthUserNamesFetched) {
        setState(() {
          _userNames = state.userNames;
          _loadingUserNames = false;
        });
      } else if (state is AuthUserNamesError) {
        setState(() {
          _loadingUserNames = false;
          _usernameFetchFailed = true;
        });
      }
    });

    super.initState();
  }

  // Helper method to get username from userId with more robust fallback
  String _getUserName(String userId) {
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    }

    // Try to extract some meaningful representation from the userId
    if (userId.length > 6) {
      return "User-${userId.substring(0, 6)}";
    }
    return "User-$userId";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settle Up'),
        centerTitle: true,
      ),
      body: BlocBuilder<SharedExpenseBloc, SharedExpenseState>(
        bloc: _sharedExpenseBloc,
        builder: (context, state) {
          if (state is SharedExpenseFetchSharedExpensesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SharedExpenseFetchSharedExpensesError) {
            return Center(
              child: Text(state.errorMessage),
            );
          } else if (state is SharedExpenseFetched) {
            final expenses = state.groupExpenses;

            if (expenses.isEmpty) {
              return const Center(
                child: Text('No expenses to settle'),
              );
            }

            // Collect all unique user IDs from expenses
            Set<String> allUserIds = {};
            for (var expense in expenses) {
              allUserIds.add(expense.paidBy);
              for (var userId in expense.splitMap.keys) {
                allUserIds.add(userId);
              }
            }

            // Initialize _userNames with empty values for all userIds
            if (_userNames.isEmpty) {
              Map<String, String> initialUserNames = {};
              for (var userId in allUserIds) {
                initialUserNames[userId] = "";
              }
              _userNames = initialUserNames;

              // Fetch user names using AuthBloc
              _authBloc.add(AuthFetchUserNames(userIDs: allUserIds.toList()));
            }

            if (_loadingUserNames) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading user information...'),
                  ],
                ),
              );
            }

            // Continue with showing expenses list - even if names are still loading
            // we'll fall back to IDs as needed
            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final description = expense.description;
                final amount = expense.amount;
                final paidById = expense.paidBy;
                final paidByName = _getUserName(paidById);
                final splitMap = expense.splitMap;
                final repayments = expense.repayments;

                // Generate settle entries from repayments and splitMap
                List<Map<String, dynamic>> settles = [];
                repayments.forEach((userId, isPaid) {
                  if (isPaid == false && userId != paidById) {
                    final amountOwed = splitMap[userId] ?? 0.0;
                    if (amountOwed > 0) {
                      settles.add({
                        'fromId': userId,
                        'fromName': _getUserName(userId),
                        'toId': paidById,
                        'toName': paidByName,
                        'amount': amountOwed,
                      });
                    }
                  }
                });

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          description,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Paid by $paidByName — Rs. $amount',
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
                        ...List.generate(settles.length, (settleIndex) {
                          final settle = settles[settleIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${settle['fromName']} owes ${settle['toName']}',
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
            );
          }

          // Default empty state
          return const Center(
            child: Text('No expenses found'),
          );
        },
      ),
    );
  }
}
