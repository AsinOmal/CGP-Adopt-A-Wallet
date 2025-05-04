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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class ScanDetailsPage extends StatefulWidget {
  final String shopName;
  final String accNumber;
  final String address;

  const ScanDetailsPage({
    super.key,
    required this.shopName,
    required this.accNumber,
    required this.address,
  });

  @override
  State<ScanDetailsPage> createState() => _QRResultState();
}

class _QRResultState extends State<ScanDetailsPage> {
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  DateTime dateTime = DateTime.now();
  late TransactionBloc _transactionBloc;
  late AuthRepository _authRepository;

  FocusNode amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    shopNameController.text = widget.shopName;
    contactInfoController.text = widget.accNumber;
    addressController.text = widget.address;
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
  }

  @override
  void dispose() {
    shopNameController.dispose();
    contactInfoController.dispose();
    addressController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {
                // Clipboard.setData(ClipboardData(text: widget.code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Copied to clipboard")),
                );
              },
              icon: const Icon(Icons.copy),
            ),
          ),
        ],
        centerTitle: true,
        title: const Center(
          child: Text(
            'Pay',
            style: TextStyle(fontSize: 20),
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
                return Center(
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
                  accountNumber: widget.accNumber,
                  amount: double.parse(amountController.text),
                  type: TransactionType.shopping,
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
                      // const SizedBox(height: 2),
                      // QrImageView(
                      //   data: widget.code,
                      //   size: 300,
                      //   version: QrVersions.auto,
                      // ),
                      // const SizedBox(height: 20),
                      // const Text(
                      //   "Scanned QR",
                      //   style: TextStyle(
                      //     color: Colors.black,
                      //     fontSize: 25,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      InputField(
                        isObsecure: false,
                        controller: shopNameController,
                        isReadOnly: true,
                        prefixIcon: Icons.maps_home_work_outlined,
                        label: 'Shop Name',
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        isObsecure: false,
                        controller: contactInfoController,
                        isReadOnly: true,
                        prefixIcon: Icons.account_balance_sharp,
                        keyboardType: TextInputType.number,
                        label: 'Contact Info',
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        isObsecure: false,
                        controller: addressController,
                        isReadOnly: true,
                        prefixIcon: Icons.location_on_outlined,
                        label: 'Address',
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        isReadOnly: false,
                        isObsecure: false,
                        prefixIcon: Icons.money,
                        focusNode: amountFocus,
                        label: 'Amount',
                        suffixIcon: TextButton(
                          onPressed: () {
                            amountController.text = '';
                          },
                          child: const Text('Clear'),
                        ),
                        prefixText: 'Rs.',
                        controller: amountController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              SimpleButton(
                data: AppLocalizations.of(context).translate('pay_now'),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  amountFocus.unfocus();
                  double amount = 0.0;
                  try {
                    amount = double.parse(amountController.text);
                  } catch (e) {
                    CustomSnackBar.showErrorSnackBar(
                        'Please enter valid amount', context);
                    return;
                  }
                  final result = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => PaymentMethodSheet(
                      amount: amount,
                      type: TransactionType.shopping,
                      billingNumber: widget.accNumber,
                    ),
                  );
                  dateTime = DateTime.now();
                  final date = DateFormat('yyyy-MM-dd').format(dateTime);
                  if (result == true) {
                    _transactionBloc.add(
                      TransactionAddEvent(
                        transaction: Transaction(
                          userID: _authRepository.userID,
                          title: widget.shopName,
                          category: 'Shopping',
                          amount: amount,
                          date: date,
                          isIncome: false,
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
