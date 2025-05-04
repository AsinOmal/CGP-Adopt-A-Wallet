import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:file_picker/file_picker.dart';
import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/transaction.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  //focus nodes
  final FocusNode amountFocusNode = FocusNode();
  final FocusNode categoryFocusNode = FocusNode();
  final FocusNode titleFocusNode = FocusNode();

  //border colors
  Color amountBorderColor = Colors.transparent;
  Color categoryBorderColor = Colors.transparent;
  Color titleBorderColor = Colors.transparent;

  FilePickerResult? result;
  late PlatformFile file;
  String? selectedCategory;

  IconData? selectedIcon;

  //transaction repo
  late TransactionBloc _transactionBloc;

  //transaction bloc
  late AuthRepository _authRepository;

  final List<Map<String, String>> incomeCategories = [
    {'name': 'Salary', 'icon': '💼'},
    {'name': 'Business', 'icon': '🏢'},
    {'name': 'Investment', 'icon': '📈'},
    {'name': 'Freelance', 'icon': '💻'},
    {'name': 'Gift', 'icon': '🎁'},
    {'name': 'Other', 'icon': '🔍'},
  ];

  void selectIcon(String? type) {
    switch (type) {
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
  void dispose() {
    amountFocusNode.dispose();
    categoryFocusNode.dispose();
    titleFocusNode.dispose();
    super.dispose();
  }

  void showIncomeTypes() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).translate('select_income_type'),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: incomeCategories.map((category) {
                    return ChoiceChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(category['icon'] ?? ''),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)
                              .translate(category['name'] ?? '')),
                        ],
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

  @override
  void initState() {
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('add_income'),
          style: const TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionLoading) {
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
          } else if (state is TransactionSuccess) {
            Navigator.pop(context);
            showSuccessSnakBar();
            _clearInputFields();
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
                        focusNode: amountFocusNode,
                        borderColor: amountBorderColor,
                        label: '0.00',
                        prefixText: 'Rs. ',
                        suffixIcon: TextButton(
                          onPressed: () {
                            amountController.text = '';
                          },
                          child: Text(
                              AppLocalizations.of(context).translate('clear')),
                        ),
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
                        focusNode: titleFocusNode,
                        borderColor: titleBorderColor,
                        isReadOnly: false,
                        label: AppLocalizations.of(context)
                            .translate('add_a_title'),
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
                                      .translate('income_type'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 10),
                                InputField(
                                  isObsecure: false,
                                  controller: categoryController,
                                  focusNode: categoryFocusNode,
                                  borderColor: categoryBorderColor,
                                  prefixIcon: selectedIcon,
                                  isReadOnly: true,
                                  label: AppLocalizations.of(context)
                                      .translate('eg_salary'),
                                  suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down_sharp),
                                  onTap: showIncomeTypes,
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
                                  AppLocalizations.of(context)
                                      .translate('date'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 10),
                                InputField(
                                  isReadOnly: true,
                                  isObsecure: false,
                                  suffixIcon: IconButton(
                                    onPressed: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        locale: const Locale('en'),
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );

                                      if (pickedDate != null) {
                                        dateController.text =
                                            DateFormat('yyyy-MM-dd')
                                                .format(pickedDate);
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
                      // const SizedBox(height: 20),
                      // Text(
                      //   AppLocalizations.of(context)
                      //       .translate('invoice_optional'),
                      //   style: const TextStyle(
                      //       fontWeight: FontWeight.bold, color: Colors.grey),
                      // ),
                      // const SizedBox(height: 10),
                      // DashedButton(
                      //   onPressed: pickFile,
                      //   icon: Icons.add_circle,
                      //   text: AppLocalizations.of(context)
                      //       .translate('add_invoice'),
                      // ),
                      // const SizedBox(height: 10),
                      // Center(
                      //   child: Text(
                      //     result != null ? file.name : '',
                      //     style: const TextStyle(
                      //       color: Colors.grey,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
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
                      TransactionAddEvent(
                        transaction: Transaction(
                          userID: _authRepository.userID,
                          title: title,
                          category: category,
                          amount: double.parse(amount),
                          date: dateController.text,
                          isIncome: true,
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
    );
  }

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: AppLocalizations.of(context).translate('successfully'),
      message: AppLocalizations.of(context)
          .translate('transaction_added_successfully'),
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

  void _clearInputFields() {
    amountController.text = '';
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    categoryController.text = '';
    titleController.text = '';
    setState(() {
      selectIcon('default');
    });
  }

  bool _validateInputs(String amount, String category, String description) {
    setState(() {
      amountBorderColor = Colors.transparent;
      categoryBorderColor = Colors.transparent;
      titleBorderColor = Colors.transparent;
    });
    if (amount.isEmpty) {
      setState(() {
        amountBorderColor = Colors.red;
      });
      String message =
          AppLocalizations.of(context).translate('enter_valid_amount');
      showErrorSnackBar(message);
      return false;
    } else if (category.isEmpty) {
      setState(() {
        categoryBorderColor = Colors.red;
      });
      String message =
          AppLocalizations.of(context).translate('select_income_category');
      showErrorSnackBar(message);
      return false;
    } else if (description.isEmpty) {
      setState(() {
        titleBorderColor = Colors.red;
      });
      String message =
          AppLocalizations.of(context).translate('enter_transaction_title');
      showErrorSnackBar(message);
      return false;
    }
    return true;
  }
}
