import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/blocs/goal/goal_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field_bottom_border.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/goal.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class GoalUpdatePopupCard extends StatefulWidget {
  String id;
  double targetAmount;
  String deadLine;
  double currentAmount;
  String title;
  final Timestamp createdAt;

  GoalUpdatePopupCard({
    super.key,
    required this.id,
    required this.targetAmount,
    required this.deadLine,
    required this.currentAmount,
    required this.title,
    required this.createdAt,
  });

  @override
  State<GoalUpdatePopupCard> createState() => _GoalUpdatePopupCardState();
}

class _GoalUpdatePopupCardState extends State<GoalUpdatePopupCard> {
  final TextEditingController amountController = TextEditingController();

  final TextEditingController targetAmountController = TextEditingController();

  final TextEditingController dateController = TextEditingController();
  bool isEditing = false;
  final TextEditingController titleController = TextEditingController();

  FocusNode targetFocusNode = FocusNode();
  String? errorMessage; // Variable to hold the error message

  late GoalBloc _goalBloc;
  late AuthRepository _authRepository;
  Goal? updatedGoal;

  bool targetAmountIsReadOnly = true;
  @override
  void initState() {
    super.initState();
    targetAmountController.text = widget.targetAmount.toString();
    titleController.text = widget.title;
    dateController.text = widget.deadLine;
    _goalBloc = RepositoryProvider.of<GoalBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
  }

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: 'Successfully!!',
      message: 'Goal is updated!',
      contentType: ContentType.success,
    );
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        widget.title = titleController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoalBloc, GoalState>(
      listener: (context, state) {
        if (state is GoalUpdateLoading) {
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
        } else if (state is GoalUpdateSuccess) {
          Navigator.pop(context);
          Navigator.pop(context, updatedGoal);
          showSuccessSnakBar();
        } else if (state is GoalUpdateError) {
          Navigator.pop(context);
          Navigator.pop(context);
          showErrorSnackBar(state.message);
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _toggleEditing,
                            child: isEditing
                                ? TextField(
                                    textAlign: TextAlign.center,
                                    controller: titleController,
                                    onSubmitted: (value) {
                                      _toggleEditing();
                                    },
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 25,
                                    ),
                                    autofocus: true,
                                  )
                                : Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 25,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: TextField(
                        cursorColor: const Color(0xFF456EFE),
                        style: const TextStyle(
                          fontSize: 25,
                          color: Color(0xFF456EFE),
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        controller: amountController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: '0.00',
                          prefixText: 'LKR',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          prefixStyle: TextStyle(
                            color: Color(0xFF456EFE),
                            fontSize: 25,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFEFEFEF),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF456EFE)),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate('target_amount_label'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: InputFieldBottomBorder(
                              prefixText: 'LKR',
                              textAlign: TextAlign.end,
                              controller: targetAmountController,
                              focusNode: targetFocusNode,
                              isReadOnly: targetAmountIsReadOnly,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormats: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*')),
                              ],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              targetAmountIsReadOnly = !targetAmountIsReadOnly;
                              if (!targetAmountIsReadOnly) {
                                targetFocusNode.requestFocus();
                              }
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 3, left: 3),
                            child: Icon(
                              Icons.edit,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate('deadline_label'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 85),
                            child: InputFieldBottomBorder(
                              textAlign: TextAlign.end,
                              controller: dateController,
                              isReadOnly: true,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(widget.deadLine),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                                locale: const Locale('en'));

                            if (pickedDate != null) {
                              dateController.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 3, left: 3),
                            child: Icon(
                              Icons.calendar_month,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${AppLocalizations.of(context).translate('current_amount_label')}: 5000",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SimpleButton(
                      data: 'update progress',
                      onPressed: () {
                        double amount;
                        double targetAmount;
                        setState(() {
                          errorMessage = '';
                        });

                        try {
                          final amountString = amountController.text.isEmpty
                              ? '0'
                              : amountController.text;
                          amount = double.parse(amountString);

                          final targetAmountString =
                              targetAmountController.text.isEmpty
                                  ? '0'
                                  : targetAmountController.text;
                          targetAmount = double.parse(targetAmountString);
                        } catch (e) {
                          setState(() {
                            errorMessage =
                                'Invalid number format. Please enter valid numeric values.';
                          });
                          return;
                        }
                        final title = titleController.text;
                        final deadline = dateController.text;
                        if (_validateInputs(amount, targetAmount, title)) {
                          _goalBloc.add(
                            GoalUpdateEvent(
                              goalID: widget.id,
                              goal: updatedGoal = Goal(
                                userID: _authRepository.userID,
                                title: title,
                                currentAmount: widget.currentAmount + amount,
                                deadline: deadline,
                                createdAt: widget.createdAt,
                                targetAmount: targetAmount,
                                id: widget.id,
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    targetAmountController.dispose();
    dateController.dispose();
    amountController.dispose();

    super.dispose();
  }

  void showErrorSnackBar(String error) {
    CustomSnackBar.show(
      context,
      title: 'On Snap!',
      message: error,
      contentType: ContentType.failure,
    );
  }

  bool _validateInputs(double amount, double targetAmount, String title) {
    if (title.isEmpty) {
      setState(() {
        errorMessage = 'Title cannot be empty.';
      });
      return false;
    }

    if (targetAmount < widget.currentAmount) {
      setState(() {
        errorMessage = 'Target amount must be greater tha current amount.';
      });
      return false;
    }

    DateTime parsedDeadline;
    try {
      parsedDeadline = DateFormat('yyyy-MM-dd').parse(dateController.text);
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid deadline format.';
      });

      return false;
    }

    if (parsedDeadline.isBefore(DateTime.now())) {
      setState(() {
        errorMessage = 'Deadline must be a future date.';
      });

      return false;
    }

    return true;
  }
}
