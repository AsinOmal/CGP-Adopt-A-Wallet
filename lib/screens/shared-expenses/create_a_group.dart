import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/blocs/shared_expense/shared_expense_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/models/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddGroupScreen extends StatefulWidget {
  static const routeName = '/create-shared-expense-group';
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late SharedExpenseBloc _sharedExpenseBloc;

  @override
  void initState() {
    super.initState();
    _sharedExpenseBloc = BlocProvider.of<SharedExpenseBloc>(context);
  }

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
      body: BlocListener<SharedExpenseBloc, SharedExpenseState>(
        listener: (context, state) {
          if (state is SharedExpenseLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                );
              },
            );
          } else if (state is SharedExpenseCreated) {
            Navigator.of(context).pop(); // Close the loading dialog
            Navigator.of(context).pop(); // Close the add group screen
          } else if (state is SharedExpenseError) {
            Navigator.of(context).pop(); // Close the loading dialog
            CustomSnackBar.showErrorSnackBar(   
              state.errorMessage,
              context
            );
          }
        },
        child: Padding(
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
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    CustomSnackBar.showErrorSnackBar(
                      'Group name cannot be empty',
                      context,
                    );
                  } else {
                    _sharedExpenseBloc.add(
                      SharedExpenseCreateRequest(
                        group: Group(
                          name: nameController.text,
                          description: descriptionController.text,
                          memberIds: [
                            'user1', // ! Replace with actual user ID
                            'user2', // ! Replace with actual user ID
                          ],
                          createdAt: Timestamp.now(),
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
//onst Color(0xFF456EFE)
