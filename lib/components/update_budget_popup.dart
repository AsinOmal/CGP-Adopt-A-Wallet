import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:financial_app/blocs/budget/budget_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field_bottom_border.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ignore: must_be_immutable
class BudgetUpdatePopup extends StatefulWidget {
  final Budget budget;
  final IconData? icon;

  const BudgetUpdatePopup(
      {super.key, required this.budget, required this.icon});

  @override
  State<BudgetUpdatePopup> createState() => _BudgetUpdatePopupState();
}

class _BudgetUpdatePopupState extends State<BudgetUpdatePopup> {
  final TextEditingController targetController = TextEditingController();

  FocusNode targetFocusNode = FocusNode();

  final List<String> _items = ['Weekly', 'Monthly'];
  String? selectedPeriod;
  bool targetAmountIsReadOnly = true;

  late BudgetBloc _budgetBloc;
  Budget? updatedBudget;
  @override
  void initState() {
    super.initState();
    selectedPeriod = widget.budget.timePeriod;
    targetController.text = widget.budget.amount.toString();
    _budgetBloc = RepositoryProvider.of<BudgetBloc>(context);
  }

  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetUpdateLoading) {
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
        } else if (state is BudgetUpdateSuccess) {
          Navigator.pop(context);
          Navigator.pop(context, updatedBudget);
          showSuccessSnakBar();
        } else if (state is BudgetUpdateError) {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 219, 228, 255),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 30,
                            color: const Color(0xFF456EFE),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.budget.category,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate('budget_amount_label'),
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
                              controller: targetController,
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
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('time_period'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              elevation: 2,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 126, 125, 125),
                              ),
                              value: selectedPeriod,
                              items: _items.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedPeriod = value;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          '',
                        ),
                      ),
                    const SizedBox(height: 30),
                    SimpleButton(
                      data: 'update budget',
                      onPressed: () {
                        setState(() {
                          errorMessage = '';
                        });
                        final amount = targetController.text;
                        if (_validateInputs(amount)) {
                          _budgetBloc.add(
                            BudgetUpdateEvent(
                              budget: updatedBudget = Budget(
                                  userID: widget.budget.userID,
                                  id: widget.budget.id,
                                  category: widget.budget.category,
                                  amount: double.parse(amount),
                                  currentAmount: widget.budget.currentAmount,
                                  timePeriod: selectedPeriod!,
                                  createdAt: widget.budget.createdAt,
                                  lastReset: widget.budget.lastReset),
                              budgetID: widget.budget.id,
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
    targetController.dispose();
    super.dispose();
  }

  bool _validateInputs(String amount) {
    if (amount.isEmpty) {
      setState(() {
        errorMessage = 'Budget amount cannot be empty';
      });
      return false;
    } else if (double.parse(amount) < widget.budget.currentAmount) {
      setState(() {
        errorMessage = 'Budget amount must be grater than current amount';
      });
      return false;
    }
    return true;
  }

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: 'Successfully!!',
      message: 'Budget is updated!',
      contentType: ContentType.success,
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
}
