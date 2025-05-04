import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/blocs/budget/budget_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/budget.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BudgetAdd extends StatefulWidget {
  const BudgetAdd({super.key});

  @override
  State<BudgetAdd> createState() => _BudgetAddState();
}

class _BudgetAddState extends State<BudgetAdd> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  String? _selectedItem;
  final List<String> repeatOptions = [
    'Weekly',
    'Monthly',
  ];
  final FocusNode amountFocusNode = FocusNode();
  final FocusNode categoryFocusNode = FocusNode();

  Color amountBorderColor = Colors.transparent;
  Color categoryBorderColor = Colors.transparent;
  Color timePeriodBorderColor = Colors.transparent;

  String? selectedCategory;

  IconData? selectedIcon;

  final List<Map<String, String>> expenseCategories = [
    {'name': 'Food', 'icon': '🍎'},
    {'name': 'Sport', 'icon': '🏀'},
    {'name': 'Health', 'icon': '💊'},
    {'name': 'Transport', 'icon': '🚌'},
    {'name': 'Shopping', 'icon': '🛍️'},
    {'name': 'Kids', 'icon': '🧸'},
    {'name': 'Entertainment', 'icon': '🎮'},
    {'name': 'Other', 'icon': '🔍'},
  ];

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
      case 'Other':
        selectedIcon = Icons.category;
        break;
      default:
        selectedIcon = null;
    }
  }

  void showExpenseTypes() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).translate('select_expense_type'),
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: expenseCategories.map((category) {
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
                            Navigator.of(context).pop(); // Dismiss dialog
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

  late AuthRepository _authRepository;
  late BudgetBloc _budgetBloc;

  @override
  void initState() {
    super.initState();
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _budgetBloc = RepositoryProvider.of<BudgetBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 30),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            _budgetBloc.add(BudgetFetchEvent(userID: _authRepository.userID));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('add_new_budget'),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: BlocListener<BudgetBloc, BudgetState>(
        bloc: _budgetBloc,
        listener: (context, state) {
          if (state is BudgetLoading) {
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
          } else if (state is BudgetSuccess) {
            Navigator.pop(context);
            showSuccessSnakBar();
            _clearFields();
          } else if (state is BudgetError) {
            Navigator.pop(context);
            showErrorSnackBar(state.message);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('amount'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      InputField(
                        isReadOnly: false,
                        isObsecure: false,
                        label: '0.00',
                        suffixIcon: TextButton(
                          onPressed: () {
                            amountController.text = '';
                          },
                          child: Text(
                            AppLocalizations.of(context).translate('clear'),
                          ),
                        ),
                        prefixText: 'Rs.',
                        focusNode: amountFocusNode,
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormat: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context).translate('time_period'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          elevation: 2,
                          hint: Text(
                            AppLocalizations.of(context)
                                .translate('select_time_period'),
                          ),
                          value: _selectedItem,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondaryFixed,
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedItem = newValue!;
                            });
                          },
                          items: repeatOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(value),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                                color: Color.fromARGB(255, 145, 145, 145)),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceDim,
                            prefixIcon: const Icon(
                              Icons.repeat,
                              color: Color(0xFF456EFE),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Repeat",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: timePeriodBorderColor),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          dropdownColor:
                              Theme.of(context).colorScheme.surfaceDim,
                          menuMaxHeight: 200,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)
                            .translate('expense_category'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      InputField(
                        isObsecure: false,
                        controller: categoryController,
                        prefixIcon: selectedIcon,
                        isReadOnly: true,
                        focusNode: categoryFocusNode,
                        label: AppLocalizations.of(context)
                            .translate('select_expense_category'),
                        suffixIcon: const Icon(Icons.keyboard_arrow_down_sharp),
                        onTap: showExpenseTypes,
                      ),
                    ],
                  ),
                ),
              ),
              SimpleButton(
                data: 'create budget',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  amountFocusNode.unfocus();
                  categoryFocusNode.unfocus();

                  final amount = amountController.text;
                  final category = categoryController.text;
                  final now = Timestamp.now();
                  if (_validateInputs(amount, category)) {
                    _budgetBloc.add(
                      BudgetAddEvent(
                        budget: Budget(
                          userID: _authRepository.userID,
                          category: category,
                          amount: double.parse(amount),
                          currentAmount: 0,
                          timePeriod: _selectedItem!,
                          createdAt: now,
                          lastReset: now,
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

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: AppLocalizations.of(context).translate('successfully'),
      message:
          AppLocalizations.of(context).translate('budget_created_successfully'),
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

  bool _validateInputs(String amount, String category) {
    setState(() {
      amountBorderColor = Colors.transparent;
      categoryBorderColor = Colors.transparent;
      timePeriodBorderColor = Colors.transparent;
    });
    if (amount.isEmpty) {
      setState(() {
        amountBorderColor = Colors.red;
      });
      String message =
          AppLocalizations.of(context).translate('enter_valid_amount');
      showErrorSnackBar(message);
      return false;
    } else if (_selectedItem == null) {
      setState(() {
        timePeriodBorderColor = Colors.red;
      });
      String message =
          AppLocalizations.of(context).translate('select_time_period_error');
      showErrorSnackBar(message);
      return false;
    } else if (category.isEmpty) {
      setState(() {
        categoryBorderColor = Colors.red;
      });
      String message = AppLocalizations.of(context)
          .translate('select_expense_category_error');
      showErrorSnackBar(message);
      return false;
    }
    return true;
  }

  void _clearFields() {
    amountController.text = '';
    categoryController.text = '';
    setState(() {
      _selectedItem = null;
      selectIcon('default');
    });
  }
}
