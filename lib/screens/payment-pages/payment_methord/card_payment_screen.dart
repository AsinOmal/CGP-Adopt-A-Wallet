import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:financial_app/blocs/card/card_bloc.dart';
import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/models/transaction.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/payment-pages/payment_success_screen.dart';
import 'package:financial_app/services/transaction_types.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:financial_app/models/card.dart';

class CardPaymentScreen extends StatefulWidget {
  final String accountNumber;
  final double amount;
  final TransactionType type;

  const CardPaymentScreen(
      {super.key,
      required this.accountNumber,
      required this.amount,
      required this.type});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  String? selectedCardType = '';
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  late TransactionBloc _transactionBloc;
  late AuthRepository _authRepository;
  late CardBloc _cardBloc;
  DateTime dateTime = DateTime.now();

  bool saveCard = false;
  Color nameBorderColor = Colors.transparent;
  Color numberBorderColor = Colors.transparent;
  Color dateBorderColor = Colors.transparent;
  Color cvvBorderColor = Colors.transparent;

  FocusNode nameFocusNode = FocusNode();
  FocusNode numberFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  FocusNode cvvFocusNode = FocusNode();

  String getTitle() {
    switch (widget.type) {
      case TransactionType.electricity:
        return 'Electricity Bill';
      case TransactionType.internet:
        return 'Internet Bill';
      case TransactionType.mobile:
        return 'Mobile Bill';
      case TransactionType.water:
        return 'Water Bill';
      case TransactionType.shopping:
        return 'Shopping';
    }
  }

  @override
  void initState() {
    super.initState();
    cardNumberController.addListener(_updateCardType);
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _cardBloc = RepositoryProvider.of<CardBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
  }

  void _updateCardType() {
    String cardNumber = cardNumberController.text.replaceAll(RegExp(r'\D'), '');
    if (cardNumber.isNotEmpty) {
      if (cardNumber.startsWith('4')) {
        setState(() {
          selectedCardType = 'Visa';
        });
      } else if (cardNumber.startsWith('5')) {
        setState(() {
          selectedCardType = 'MasterCard';
        });
      } else {
        setState(() {
          selectedCardType = null;
        });
      }
    } else {
      setState(() {
        selectedCardType = null;
      });
    }
  }

  @override
  void dispose() {
    cardNumberController.removeListener(_updateCardType);
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: ImageIcon(
              AssetImage('assets/icons/scan.ico'),
            ),
          )
        ],
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
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitThreeBounce(
                        color: Colors.white,
                        size: 50.0,
                      ),
                      SizedBox(height: 10),
                      Text('Processing payment..')
                    ],
                  ),
                );
              },
            );
          } else if (state is TransactionSuccess) {
            Navigator.pop(context);
            _transactionBloc
                .add(TransactionFetchEvent(userID: _authRepository.userID));
            _cardBloc.add(CardFetchEvent(userID: _authRepository.userID));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessScreen(
                  accountNumber: widget.accountNumber,
                  amount: widget.amount,
                  type: widget.type,
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
          padding: const EdgeInsets.only(
            left: 25,
            right: 25,
            bottom: 25,
            top: 25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 10,
                      right: 10,
                      left: 10,
                      bottom: 30,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surfaceDim,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _buildCardTypeSelection(),
                        const SizedBox(height: 16),
                        InputField(
                          isObsecure: false,
                          controller: nameController,
                          borderColor: nameBorderColor,
                          focusNode: nameFocusNode,
                          isReadOnly: false,
                          label: 'Card Holder Name',
                          inputFormat: [
                            LengthLimitingTextInputFormatter(16),
                          ],
                        ),
                        const SizedBox(height: 20),
                        InputField(
                          isObsecure: false,
                          controller: cardNumberController,
                          borderColor: numberBorderColor,
                          focusNode: numberFocusNode,
                          isReadOnly: false,
                          label: 'Card Number',
                          keyboardType: TextInputType.number,
                          inputFormat: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            CardNumberInputFormatter(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: InputField(
                                isObsecure: false,
                                controller: expiryDateController,
                                borderColor: dateBorderColor,
                                focusNode: dateFocusNode,
                                isReadOnly: false,
                                label: 'MM/YY',
                                keyboardType: TextInputType.number,
                                inputFormat: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  ExpiryDateInputFormatter(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: InputField(
                                isObsecure: false,
                                controller: cvvController,
                                borderColor: cvvBorderColor,
                                focusNode: cvvFocusNode,
                                isReadOnly: false,
                                keyboardType: TextInputType.number,
                                label: 'CVV',
                                inputFormat: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Checkbox(
                              value: saveCard,
                              onChanged: (value) {
                                setState(() {
                                  saveCard = value ?? false;
                                });
                              },
                            ),
                            const Text('Save Card Details'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _buildAmountDisplay(),
                      ],
                    ),
                  ),
                ),
              ),
              SimpleButton(
                data: 'Pay Now',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  nameFocusNode.unfocus();
                  numberFocusNode.unfocus();
                  cvvFocusNode.unfocus();
                  cvvFocusNode.unfocus();
                  String name = nameController.text;
                  String cardNumber = cardNumberController.text;
                  String expireDate = expiryDateController.text;
                  String cvv = cvvController.text;
                  if (_validateInputs(name, cardNumber, expireDate, cvv)) {
                    if (saveCard) {
                      _cardBloc.add(
                        CardAddEvent(
                          card: Card(
                            userID: _authRepository.userID,
                            cardholderName: name,
                            cardNumber: cardNumber,
                            expireDate: expireDate,
                            cvv: cvv,
                            isVisa: selectedCardType == 'Visa' ? true : false,
                            createdAt: Timestamp.now(),
                          ),
                        ),
                      );
                    }
                    dateTime = DateTime.now();
                    final date = DateFormat('yyyy-MM-dd').format(dateTime);
                    _transactionBloc.add(
                      TransactionAddEvent(
                        transaction: Transaction(
                          userID: _authRepository.userID,
                          title: getTitle(),
                          category: 'Utility',
                          amount: widget.amount,
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

  bool _validateInputs(
      String name, String cardNumber, String expireDate, String cvv) {
    setState(() {
      nameBorderColor = Colors.transparent;
      numberBorderColor = Colors.transparent;
      dateBorderColor = Colors.transparent;
      cvvBorderColor = Colors.transparent;
    });

    if (name.isEmpty) {
      setState(() {
        nameBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Name must be required', context);
      return false;
    } else if (cardNumber.isEmpty) {
      setState(() {
        numberBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Card number must be required', context);
      return false;
    } else if (cardNumber.length != 19) {
      setState(() {
        numberBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'Card number must have 16 characters', context);
      return false;
    } else if (expireDate.isEmpty) {
      setState(() {
        dateBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Expire date must be required', context);
      return false;
    } else if (expireDate.length != 5 || isFutureDate(expireDate)) {
      setState(() {
        dateBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Invalid expire date', context);
      return false;
    } else if (cvv.isEmpty || cvv.length != 3) {
      setState(() {
        cvvBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Invalid CVV!', context);
      return false;
    }
    return true;
  }

  bool isFutureDate(String expireDate) {
    // Split the input to get month and year parts
    final parts = expireDate.split('/');
    if (parts.length != 2) return true; // Ensure input format is correct

    final int month = int.tryParse(parts[0]) ?? 0;
    final int year = int.tryParse(parts[1]) ?? 0;

    if (month < 1 || month > 12) return true; // Check if month is valid

    // Get the current date
    final DateTime now = DateTime.now();
    final int currentYear =
        now.year % 100; // Get the last two digits of the year
    final int currentMonth = now.month;

    // Check if the entered year and month are in the future
    if (year > currentYear || (year == currentYear && month >= currentMonth)) {
      return false;
    }

    return true;
  }

  Widget _buildCardTypeSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildCardRadio('Visa'),
        const SizedBox(width: 20),
        _buildCardRadio('MasterCard'),
      ],
    );
  }

  Widget _buildCardRadio(String cardType) {
    return Row(
      children: [
        Radio<String>(
          value: cardType,
          groupValue: selectedCardType,
          onChanged: (value) {
            setState(() {
              selectedCardType = value;
            });
          },
        ),
        Text(cardType),
      ],
    );
  }

  Widget _buildAmountDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Amount: ',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          'Rs.${widget.amount}',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      if (i % 4 == 0 && i != 0) formattedText += ' ';
      formattedText += newText[i];
    }
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formattedText = '';
    if (newText.length > 2) {
      formattedText =
          '${newText.substring(0, 2)}/${newText.substring(2, newText.length)}';
    } else {
      formattedText = newText;
    }
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
