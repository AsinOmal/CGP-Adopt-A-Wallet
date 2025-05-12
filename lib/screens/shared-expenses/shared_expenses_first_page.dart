// ignore_for_file: use_build_context_synchronously

import 'package:financial_app/blocs/shared_expense/shared_expense_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/models/group.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/shared-expenses/group_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class SharedExpensePage extends StatefulWidget {
  static const routeName = '/group-sharing-first';

  const SharedExpensePage({super.key});

  @override
  State<SharedExpensePage> createState() => _SharedExpensePageState();
}

class _SharedExpensePageState extends State<SharedExpensePage> {
  final List<Group> groups = [];

  late SharedExpenseBloc _sharedExpenseBloc;
  late AuthRepository _authRepository;

  @override
  void initState() {
    _sharedExpenseBloc = RepositoryProvider.of<SharedExpenseBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _sharedExpenseBloc
        .add(SharedExpenseFetchGroupsRequest(userId: _authRepository.userID));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Shared Expenses",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: BlocListener<SharedExpenseBloc, SharedExpenseState>(
        listener: (context, state) {
          if (state is SharedExpenseGroupsLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          } else if (state is SharedExpenseGroupsFetched) {
            Navigator.of(context).pop();
            setState(() {
              groups.clear();
              groups.addAll(state.groups);
            });
          } else if (state is SharedExpenseGroupsError) {
            Navigator.of(context).pop(); // Close the loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Manage your shared expenses with friends and family",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Expanded(
                  child: LiquidPullToRefresh(
                    onRefresh: () async {
                      _sharedExpenseBloc.add(SharedExpenseFetchGroupsRequest(
                          userId: _authRepository.userID));
                    },
                    color: Theme.of(context).primaryColor,
                    height: 50,
                    animSpeedFactor: 2,
                    showChildOpacityTransition: false,
                    child: groups.isNotEmpty
                        ? ListView.separated(
                            itemCount: groups.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildGroupCard(groups[index], index);
                            },
                          )
                        : const Center(
                            child: Text(
                              "No groups found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(Group group, int index) {
    return Slidable(
      key: ValueKey(group.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              _sharedExpenseBloc.add(
                SharedExpenseDeleteGroupRequest(
                  groupId: group.id,
                ),
              );
              _sharedExpenseBloc.stream.listen((state) {
                if (state is SharedExpenseGroupDeleted) {
                  CustomSnackBar.showSuccessSnackBar(
                      "Group deleted successfully", context);
                  setState(() {
                    groups.removeAt(index);
                  });
                  
                } else if (state is SharedExpenseError) {
                  CustomSnackBar.showErrorSnackBar(
                      "Failed to delete group: ${state.errorMessage}", context);
                }
              });
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 185, 184, 184).withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          title: Text(
            group.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailsScreen(group: group),
              ),
            );
          }, // Add navigation or functionality here
        ),
      ),
    );
  }
}
