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
import 'package:financial_app/services/image_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
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

  //transaction bloc
  late TransactionBloc _transactionBloc;

  //auth repo
  late AuthRepository _authRepository;

  final List<Map<String, String>> expenseCategories = [
    {'name': 'Food', 'icon': '🍎'},
    {'name': 'Sport', 'icon': '🏀'},
    {'name': 'Health', 'icon': '💊'},
    {'name': 'Transport', 'icon': '🚌'},
    {'name': 'Shopping', 'icon': '🛍️'},
    {'name': 'Kids', 'icon': '🧸'},
    {'name': 'Entertainment', 'icon': '🎮'},
    {'name': 'Education', 'icon': '🎓'},
    {'name': 'Utility', 'icon': '💡'},
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
      case 'Utility':
        selectedIcon = Icons.lightbulb;
        break;
      case 'Education':
        selectedIcon = Icons.school;
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

  @override
  void initState() {
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    super.initState();
  }

  final ImageScanner imageScanner = ImageScanner();

  // Existing controllers and other state variables...

  Future<void> _getImage() async {
    final XFile? image = await imageScanner.pickImage();
    if (image != null) {
      await imageScanner.processImage(image.path, _parseReceiptText);
    }
  }

  void _parseReceiptText(String text) {
    imageScanner.parseReceiptText(text, _populateTransactionFields);
  }

  void _populateTransactionFields(
      double? amount, String? category, String? date, String? description) {
    amountController.text = amount?.toString() ?? '';
    categoryController.text = category ?? 'Uncategorized';
    dateController.text = date ?? '';
    titleController.text = description ?? '';
    selectIcon(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('add_expense'),
          style: const TextStyle(fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const ImageIcon(AssetImage('assets/icons/scan.ico')),
            onPressed: _getImage,
          )
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionLoading) {
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
          } else if (state is TransactionSuccess) {
            Navigator.pop(context);
            showSuccessSnakBar();
            _clearInputFields();
          } else if (state is TransactionError) {
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
                          child: Text(
                              AppLocalizations.of(context).translate('clear')),
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
                                      .translate('expense_type'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 10),
                                InputField(
                                  isObsecure: false,
                                  controller: categoryController,
                                  borderColor: categoryBorderColor,
                                  prefixIcon: selectedIcon,
                                  focusNode: categoryFocusNode,
                                  isReadOnly: true,
                                  label: AppLocalizations.of(context)
                                      .translate('eg_food'),
                                  suffixIcon: const Icon(
                                      Icons.keyboard_arrow_down_sharp),
                                  onTap: showExpenseTypes,
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
                          isIncome: false,
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

  bool _validateInputs(String amount, String category, String title) {
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
          AppLocalizations.of(context).translate('select_expense_category');
      showErrorSnackBar(message);
      return false;
    } else if (title.isEmpty) {
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
