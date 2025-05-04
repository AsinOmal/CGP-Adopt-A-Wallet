import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/transaction.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/payment-pages/payment_methord/show_payment_methods.dart';
import 'package:financial_app/screens/payment-pages/payment_success_screen.dart';
import 'package:financial_app/services/transaction_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class ElectricityBillScreen extends StatefulWidget {
  const ElectricityBillScreen({super.key});

  @override
  State<ElectricityBillScreen> createState() => _ElectricityBillScreenState();
}

class _ElectricityBillScreenState extends State<ElectricityBillScreen> {
  final TextEditingController confirmAccountNumberController =
      TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  Color accNumBorderColor = Colors.transparent;
  Color confirmAccNumBorderColor = Colors.transparent;
  Color amountBorderColor = Colors.transparent;
  DateTime dateTime = DateTime.now();

  final FocusNode accNumNode = FocusNode();
  final FocusNode confirmAccNumNode = FocusNode();
  final FocusNode amountNode = FocusNode();
  late TransactionBloc _transactionBloc;
  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
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
        centerTitle: true,
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('electricity_bill_payment'),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listenWhen: (previous, current) {
          return current is TransactionSuccess ||
              current is TransactionLoading ||
              current is TransactionError;
        },
        listener: (context, state) {
          if (state is TransactionLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return  Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SpinKitThreeBounce(
                        color: Colors.white,
                        size: 50.0,
                      ),
                      const SizedBox(height: 10),
                      Text(AppLocalizations.of(context).translate('processing_payment'))
                    ],
                  ),
                );
              },
            );
          } else if (state is TransactionSuccess) {
            Navigator.pop(context);
            _transactionBloc
                .add(TransactionFetchEvent(userID: _authRepository.userID));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessScreen(
                  accountNumber: accountNumberController.text,
                  amount: double.parse(amountController.text),
                  type: TransactionType.electricity,
                  dateTime: dateTime,
                ),
              ),
            );
          } else if (state is TransactionError) {
            Navigator.pop(context);
            CustomSnackBar.showErrorSnackBar(
                'Payment failed! Try again later', context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.blue,
                        child:
                            Icon(Icons.flash_on, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 40),
                       Text(
                        AppLocalizations.of(context).translate('enter_payment_details'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 40),
                      InputField(
                        isObsecure: false,
                        controller: accountNumberController,
                        isReadOnly: false,
                        prefixIcon: Icons.numbers,
                        focusNode: accNumNode,
                        borderColor: accNumBorderColor,
                        keyboardType: TextInputType.number,
                        inputFormat: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        label: AppLocalizations.of(context).translate('account_number'),
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        isObsecure: false,
                        controller: confirmAccountNumberController,
                        focusNode: confirmAccNumNode,
                        borderColor: confirmAccNumBorderColor,
                        isReadOnly: false,
                        inputFormat: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        prefixIcon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        label: AppLocalizations.of(context).translate('confirm_account_number'),
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        isReadOnly: false,
                        isObsecure: false,
                        focusNode: amountNode,
                        prefixIcon: Icons.money,
                        borderColor: amountBorderColor,
                        label: AppLocalizations.of(context).translate('amount'),
                        suffixIcon: TextButton(
                          onPressed: () {
                            amountController.text = '';
                          },
                          child: Text(AppLocalizations.of(context).translate('clear')),
                        ),
                        prefixText: 'Rs.',
                        controller: amountController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SimpleButton(
                data: AppLocalizations.of(context).translate('pay_bill'),
                onPressed: () async {
                  accNumNode.unfocus();
                  confirmAccNumNode.unfocus();
                  amountNode.unfocus();
                  FocusScope.of(context).unfocus();
                  String accNum = accountNumberController.text;
                  String confirmAccNum = confirmAccountNumberController.text;
                  double amount = 0.0;
                  try {
                    amount = double.parse(amountController.text);
                  } catch (e) {
                    CustomSnackBar.showErrorSnackBar(
                        'Please enter valid amount', context);
                    return;
                  }
                  if (_validateInputs(accNum, confirmAccNum, amount)) {
                    final result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => PaymentMethodSheet(
                        amount: amount,
                        type: TransactionType.electricity,
                        billingNumber: accNum,
                      ),
                    );
                    dateTime = DateTime.now();
                    final date = DateFormat('yyyy-MM-dd').format(dateTime);
                    if (mounted && result == true) {
                      _transactionBloc.add(
                        TransactionAddEvent(
                          transaction: Transaction(
                            userID: _authRepository.userID,
                            title: 'Electricity Bill',
                            category: 'Utility',
                            amount: amount,
                            date: date,
                            isIncome: false,
                            createdAt: Timestamp.now(),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs(String accNum, String confirmAccNum, double amount) {
    setState(() {
      accNumBorderColor = Colors.transparent;
      confirmAccNumBorderColor = Colors.transparent;
      amountBorderColor = Colors.transparent;
    });
    if (accNum.isEmpty) {
      setState(() {
        accNumBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Please enter account number', context);
      return false;
    } else if (accNum.length != 10) {
      setState(() {
        accNumBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'Please enter valid account number', context);
      return false;
    } else if (confirmAccNum.isEmpty) {
      setState(() {
        confirmAccNumBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'Please re-enter account number', context);
      return false;
    } else if (confirmAccNum.length != 10) {
      setState(() {
        confirmAccNumBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'Please re-enter valid account number', context);
      return false;
    } else if (confirmAccNum != accNum) {
      setState(() {
        confirmAccNumBorderColor = Colors.red;
        accNumBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Account number didn\'t match', context);
      return false;
    } else if (amount == 0.0) {
      setState(() {
        amountBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Amount must be required', context);
      return false;
    } else if (amount < 100) {
      setState(() {
        amountBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'Amount must be geater than LKR 100', context);
      return false;
    }
    return true;
  }
}
