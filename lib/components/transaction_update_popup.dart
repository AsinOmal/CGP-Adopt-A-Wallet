import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/dashed_border_button.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'custome_snackbar.dart';

class TransactionUpdatePopup extends StatefulWidget {
  final Transaction transaction;
  const TransactionUpdatePopup({super.key, required this.transaction});

  @override
  State<TransactionUpdatePopup> createState() => _TransactionUpdatePopupState();
}

class _TransactionUpdatePopupState extends State<TransactionUpdatePopup> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();
  final FocusNode categoryFocusNode = FocusNode();
  final FocusNode titleFocusNode = FocusNode();
  String? errorMessage;
  Transaction? updatedTransaction;

  //border colors
  Color amountBorderColor = Colors.transparent;
  Color categoryBorderColor = Colors.transparent;
  Color titleBorderColor = Colors.transparent;

  FilePickerResult? result;
  late PlatformFile file;

  //transaction bloc
  late TransactionBloc _transactionBloc;

  String? selectedCategory;
  final List<Map<String, String>> expenseCategories = [
    {'name': 'Food', 'icon': '🍎'},
    {'name': 'Sport', 'icon': '🏀'},
    {'name': 'Health', 'icon': '💊'},
    {'name': 'Transport', 'icon': '🚌'},
    {'name': 'Shopping', 'icon': '🛍️'},
    {'name': 'Kids', 'icon': '🧸'},
    {'name': 'Entertainment', 'icon': '🎮'},
    {'name': 'Education', 'icon': '🎓'},
    {'name': 'Other', 'icon': '🔍'},
  ];

  final List<Map<String, String>> incomeCategories = [
    {'name': 'Salary', 'icon': '💼'},
    {'name': 'Business', 'icon': '🏢'},
    {'name': 'Investment', 'icon': '📈'},
    {'name': 'Freelance', 'icon': '💻'},
    {'name': 'Gift', 'icon': '🎁'},
    {'name': 'Other', 'icon': '🔍'},
  ];

  IconData? selectedIcon;
  void showCategories() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            widget.transaction.isIncome
                ? 'Select Income Type'
                : 'Select Expense Type',
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: widget.transaction.isIncome
                      ? incomeCategories.map((category) {
                          return ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            label: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(category['icon'] ?? ''),
                                  const SizedBox(width: 6),
                                  Text(AppLocalizations.of(context)
                                      .translate(category['name'] ?? '')),
                                ],
                              ),
                            ),
                            selected: selectedCategory == category['name'],
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedCategory = category['name'];
                                  categoryController.text = category['name']!;
                                  selectIcon(selectedCategory);
                                  Navigator.of(context).pop();
                                }
                              });
                            },
                          );
                        }).toList()
                      : expenseCategories.map((category) {
                          return ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            label: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(category['icon'] ?? ''),
                                  const SizedBox(width: 6),
                                  Text(AppLocalizations.of(context)
                                      .translate(category['name'] ?? '')),
                                ],
                              ),
                            ),
                            selected: selectedCategory == category['name'],
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedCategory = category['name'];
                                  categoryController.text = category['name']!;
                                  selectIcon(selectedCategory);
                                  Navigator.of(context).pop();
                                }
                              });
                            },
                          );
                        }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void selectIcon(String? type) {
    switch (type) {
      case 'Food':
        selectedIcon = Icons.fastfood;
        break;
      case 'Sport':
        selectedIcon = Icons.sports_basketball;
        break;
      case 'Health':
        selectedIcon = Icons.health_and_safety;
        break;
      case 'Transport':
        selectedIcon = Icons.directions_car;
        break;
      case 'Shopping':
        selectedIcon = Icons.shopping_cart;
        break;
      case 'Kids':
        selectedIcon = Icons.child_care;
        break;
      case 'Entertainment':
        selectedIcon = Icons.theaters;
        break;
      case 'Education':
        selectedIcon = Icons.school;
        break;
      case 'Salary':
        selectedIcon = Icons.monetization_on;
        break;
      case 'Business':
        selectedIcon = Icons.business;
        break;
      case 'Investment':
        selectedIcon = Icons.show_chart;
        break;
      case 'Freelance':
        selectedIcon = Icons.work;
        break;
      case 'Gift':
        selectedIcon = Icons.card_giftcard;
        break;
      case 'Other':
        selectedIcon = Icons.category;
        break;
      default:
        selectedIcon = null;
    }
  }

  void pickFile() async {
    result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file = result!.files.first;
      });
      // handle event
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    amountController.text = widget.transaction.amount.toString();
    titleController.text = widget.transaction.title;
    categoryController.text = widget.transaction.category;
    dateController.text = widget.transaction.date;
    selectIcon(widget.transaction.category);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionUpdateLoading) {
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
        } else if (state is TrnsactionUpdateSuccess) {
          Navigator.pop(context);
          Navigator.pop(context, updatedTransaction);
          showSuccessSnakBar();
        } else if (state is TransactionUpdateError) {
          Navigator.pop(context);
          Navigator.pop(context);
          showErrorSnackBar(state.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context).translate('amount'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              InputField(
                isReadOnly: false,
                isObsecure: false,
                borderColor: amountBorderColor,
                focusNode: amountFocusNode,
                label: '0.00',
                suffixIcon: TextButton(
                  onPressed: () {
                    amountController.text = '';
                  },
                  child: Text(AppLocalizations.of(context).translate('clear')),
                ),
                prefixText: 'Rs. ',
                controller: amountController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).translate('title'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              InputField(
                isObsecure: false,
                controller: titleController,
                borderColor: titleBorderColor,
                focusNode: titleFocusNode,
                isReadOnly: false,
                label: AppLocalizations.of(context).translate('add_a_title'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate('expense_type'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        InputField(
                          isObsecure: false,
                          controller: categoryController,
                          borderColor: categoryBorderColor,
                          prefixIcon: selectedIcon,
                          focusNode: categoryFocusNode,
                          isReadOnly: true,
                          label:
                              AppLocalizations.of(context).translate('eg_food'),
                          suffixIcon:
                              const Icon(Icons.keyboard_arrow_down_sharp),
                          onTap: showCategories,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('date'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        InputField(
                          isReadOnly: true,
                          isObsecure: false,
                          suffixIcon: IconButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                locale: const Locale('en'),
                              );

                              if (pickedDate != null) {
                                dateController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              }
                            },
                            icon: const Icon(Icons.date_range),
                          ),
                          controller: dateController,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).translate('invoice_optional'),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              DashedButton(
                onPressed: pickFile,
                icon: Icons.add_circle,
                text: AppLocalizations.of(context).translate('add_invoice'),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  result != null ? file.name : '',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 5),
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
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              SimpleButton(
                data: 'save',
                onPressed: () {
                  amountFocusNode.unfocus();
                  categoryFocusNode.unfocus();
                  titleFocusNode.unfocus();

                  final amount = amountController.text;
                  final category = categoryController.text;
                  final title = titleController.text;

                  if (_validateInputs(amount, category, title)) {
                    _transactionBloc.add(
                      TransactionUpdateEvent(
                        transactionID: widget.transaction.id,
                        transaction: updatedTransaction = Transaction(
                          userID: widget.transaction.userID,
                          id: widget.transaction.id,
                          title: title,
                          category: category,
                          amount: double.parse(amount),
                          date: dateController.text,
                          isIncome: widget.transaction.isIncome,
                          createdAt: widget.transaction.createdAt,
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
    );
  }

  bool _validateInputs(String amount, String category, String title) {
    setState(() {
      amountBorderColor = Colors.transparent;
      categoryBorderColor = Colors.transparent;
      titleBorderColor = Colors.transparent;
      errorMessage = '';
    });
    if (amount.isEmpty) {
      setState(() {
        amountBorderColor = Colors.red;
        String message =
            AppLocalizations.of(context).translate('enter_valid_amount');
        errorMessage = message;
      });
      return false;
    } else if (category.isEmpty) {
      setState(() {
        categoryBorderColor = Colors.red;
        String message =
            AppLocalizations.of(context).translate('select_expense_category');
        errorMessage = message;
      });
      return false;
    } else if (title.isEmpty) {
      setState(() {
        titleBorderColor = Colors.red;
        String message =
            AppLocalizations.of(context).translate('enter_transaction_title');
        errorMessage = message;
      });
      return false;
    }
    return true;
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
      message: AppLocalizations.of(context)
          .translate('transaction_updated_successfully'),
      contentType: ContentType.success,
    );
  }
}
