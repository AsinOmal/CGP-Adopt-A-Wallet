import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/input_field.dart';
import '../../../components/simple_button.dart';

class WaterBillScreen extends StatefulWidget {
  const WaterBillScreen({super.key});

  @override
  State<WaterBillScreen> createState() => _WaterBillScreenState();
}

class _WaterBillScreenState extends State<WaterBillScreen> {
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

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
            AppLocalizations.of(context).translate('water_bill_payment'),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.orangeAccent,
                      child: Icon(Icons.water, size: 50, color: Colors.white),
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
                      prefixIcon: Icons.account_circle,
                      keyboardType: TextInputType.number,
                      label: AppLocalizations.of(context).translate('account_number'),
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      isReadOnly: false,
                      isObsecure: false,
                      label: AppLocalizations.of(context).translate('amount'),
                      prefixIcon: Icons.money,
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
                    InputField(
                      isReadOnly: true,
                      isObsecure: false,
                      label: AppLocalizations.of(context).translate('due_date'),
                      prefixIcon: Icons.date_range,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            dueDateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      controller: dueDateController,
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      isReadOnly: true,
                      isObsecure: false,
                      label: AppLocalizations.of(context).translate('date_of_payment'),
                      prefixIcon: Icons.date_range,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            paymentDateController.text =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                          }
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      controller: paymentDateController,
                    ),
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
            SimpleButton(
              data: AppLocalizations.of(context).translate('pay_bill'),
              onPressed: () {
                if (accountNumberController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  // Add your payment processing logic here
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Please fill in all fields'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
