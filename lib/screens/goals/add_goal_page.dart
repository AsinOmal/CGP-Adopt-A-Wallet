import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/blocs/goal/goal_bloc.dart';
import 'package:financial_app/components/input_field_bottom_border.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/goal.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../../components/custome_snackbar.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController targetAmountController = TextEditingController();
  final TextEditingController currentAmountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String enteredAmount = '0.00';
  String enteredDate = '';

  late GoalBloc _goalBloc;
  late AuthRepository _authRepository;

  Color targetAmountBorderColor = const Color(0xFFEFEFEF);
  Color currentAmountBorderColor = const Color(0xFFEFEFEF);
  Color dateBorderColor = const Color(0xFFEFEFEF);
  Color titleBorderColor = const Color(0xFFEFEFEF);

  @override
  void initState() {
    super.initState();
    _goalBloc = RepositoryProvider.of<GoalBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    currentAmountController.text = '0.00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            _goalBloc.add(GoalFetchEvent(userID: _authRepository.userID));
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocListener<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalLoading) {
            showDialog(
              context: context,
              builder: (context) {
                return const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                );
              },
            );
          } else if (state is GoalSuccess) {
            Navigator.pop(context);
            showSuccessSnakBar();
            _clearInputFields();
          } else if (state is GoalAddError) {
            Navigator.pop(context);
            showErrorSnackBar(state.message);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(25),
              child: Text(
                AppLocalizations.of(context)
                    .translate('create_new_saving_goal'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate('enter_your_plan'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InputFieldBottomBorder(
                          isReadOnly: false,
                          controller: titleController,
                          borderColor: titleBorderColor,
                        ),
                        const SizedBox(height: 45),
                        Text(
                          AppLocalizations.of(context)
                              .translate('target_amount'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InputFieldBottomBorder(
                          onChange: (value) {
                            setState(() {
                              enteredAmount = value;
                            });
                          },
                          isReadOnly: false,
                          controller: targetAmountController,
                          borderColor: targetAmountBorderColor,
                          keyboardType: TextInputType.number,
                          prefixText: 'Rs.',
                        ),
                        const SizedBox(height: 45),
                        Text(
                          AppLocalizations.of(context)
                              .translate('current_amount'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InputFieldBottomBorder(
                          onChange: (value) {
                            setState(() {
                              enteredAmount = value;
                            });
                          },
                          isReadOnly: false,
                          controller: currentAmountController,
                          borderColor: targetAmountBorderColor,
                          keyboardType: TextInputType.number,
                          prefixText: 'Rs.',
                        ),
                        const SizedBox(height: 45),
                        Text(
                          AppLocalizations.of(context).translate('deadline'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InputFieldBottomBorder(
                          isReadOnly: true,
                          controller: dateController,
                          borderColor: dateBorderColor,
                          suffixIcon: const Icon(
                            Icons.calendar_month_rounded,
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2099),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                                enteredDate =
                                    DateFormat('MMM yyyy').format(pickedDate);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF456EFE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Text(
                      'You will save Rs.$enteredAmount by',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      enteredDate.isEmpty ? 'Select a deadline' : enteredDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 20), // Add some space
                    SimpleButton(
                      textColor: const Color(0xFF456EFE),
                      color: Colors.white,
                      data: 'create goal',
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        final title = titleController.text;
                        final targetAmount = targetAmountController.text;
                        final date = dateController.text;
                        final currentAmount = currentAmountController.text == ''
                            ? '0'
                            : currentAmountController.text;
                        if (validateInputs(title, targetAmount, date)) {
                          _goalBloc.add(
                            GoalAddEvent(
                              goal: Goal(
                                userID: _authRepository.userID,
                                title: title,
                                targetAmount: double.parse(targetAmount),
                                currentAmount: double.parse(currentAmount),
                                deadline: date,
                                createdAt: Timestamp.now(),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showErrorSnackBar(String error) {
    CustomSnackBar.show(
      context,
      title: 'On Snap!',
      message: error,
      contentType: ContentType.failure,
    );
  }

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: AppLocalizations.of(context).translate('successfully'),
      message:
          AppLocalizations.of(context).translate('goal_added_successfully'),
      contentType: ContentType.success,
    );
  }

  void _clearInputFields() {
    titleController.text = '';
    targetAmountController.text = '';
    dateController.text = '';
    currentAmountController.text = '0.00';
  }

  bool validateInputs(String title, String targetAmount, String date) {
    setState(() {
      targetAmountBorderColor = const Color(0xFFEFEFEF);
      dateBorderColor = const Color(0xFFEFEFEF);
      titleBorderColor = const Color(0xFFEFEFEF);
      currentAmountBorderColor = const Color(0xFFEFEFEF);
    });
    if (title.isEmpty) {
      setState(() {
        titleBorderColor = Colors.red;
      });
      showErrorSnackBar('Please enter a title for the goal.');
      return false;
    } else if (targetAmount.isEmpty) {
      setState(() {
        targetAmountBorderColor = Colors.red;
      });
      showErrorSnackBar('Please enter a valid target amount.');
      return false;
    } else if (date.isEmpty) {
      setState(() {
        dateBorderColor = Colors.red;
      });
      showErrorSnackBar('Please select a deadline.');
      return false;
    }
    return true;
  }
}
