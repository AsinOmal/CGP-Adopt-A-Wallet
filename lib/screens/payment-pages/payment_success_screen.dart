import 'dart:math';

import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/services/transaction_types.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String accountNumber;
  final double amount;
  final TransactionType type;
  final DateTime dateTime;

  const PaymentSuccessScreen({
    super.key,
    required this.accountNumber,
    required this.amount,
    required this.type,
    required this.dateTime,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
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

  String generateTransactionId() {
    const prefix = 'TXN';
    final random = Random();
    final number = random.nextInt(900000000) + 100000000; // Ensures 9 digits
    return '$prefix$number';
  }

  void showBottomDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.accountNumber,
                  style: const TextStyle(
                    color: Color(0xFFA4A9AE),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: BorderRadius.circular(10)),
                  child:  Text.rich(
                    TextSpan(
                      text: AppLocalizations.of(context).translate('transaction_status'), // Regular text
                      style: const TextStyle(
                        color: Color(0xFF13c999),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: AppLocalizations.of(context).translate('paid'), // Bold text
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    text: 'Rs.', // Regular text
                    style: const TextStyle(fontSize: 30),
                    children: <TextSpan>[
                      TextSpan(
                        text: widget.amount.toStringAsFixed(2), // Bold text
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      AppLocalizations.of(context).translate('transaction_id'),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(generateTransactionId()),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  color: Color(0xFFebf1f5),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      AppLocalizations.of(context).translate('date'),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(DateFormat('yyyy-MM-dd').format(widget.dateTime)),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  color: Color(0xFFebf1f5),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      AppLocalizations.of(context).translate('time'),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(DateFormat.jm().format(widget.dateTime)),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 25,
          right: 25,
          top: 50,
          bottom: 25,
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 15),
               Text(
                AppLocalizations.of(context).translate('payment_successful'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF456EFE),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
               Text(
                AppLocalizations.of(context).translate('thank_you_payment'),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 100),
              Image.asset(
                'assets/images/success.png',
                width: 300,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => showBottomDialog(context),
                child: Text(AppLocalizations.of(context).translate('view_receipt')),
              ),
              const SizedBox(
                height: 10,
              ),
              SimpleButton(
                data: AppLocalizations.of(context).translate('done'),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
