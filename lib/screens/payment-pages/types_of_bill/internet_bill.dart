import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/clickble_textfield.dart';
import '../../../components/input_field.dart';

class InternetBillScreen extends StatefulWidget {
  const InternetBillScreen({super.key});

  @override
  State<InternetBillScreen> createState() => _InternetBillScreenState();
}

class _InternetBillScreenState extends State<InternetBillScreen> {
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController selectBillerController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    paymentDateController.text =
        DateTime.now().toLocal().toString().split(' ')[0];
  }

  final List<String> billers = ['SLT Mobitel', 'Dialog Broadband', 'Lankabell'];

  String? selectedBiller;

  void _showBillerSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('select_biller')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: billers.map((biller) {
              return ListTile(
                title: Text(biller),
                onTap: () {
                  setState(() {
                    selectBillerController.text = biller;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
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
            AppLocalizations.of(context).translate('internet_bill_payment'),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.wifi, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                     Text(
                      AppLocalizations.of(context).translate('enter_payment_details'),
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    ClickbleTextfield(
                      prefixIcon: Icons.cell_tower,
                      controller: selectBillerController,
                      label: AppLocalizations.of(context).translate('select_biller'),
                      onTap: () => _showBillerSelectionDialog(),
                    ),
                    const SizedBox(height: 16),
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
                      prefixIcon: Icons.money,
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
                  ],
                ),
              ),
            ),
            SimpleButton(
              data: AppLocalizations.of(context).translate('pay_bill'),
              onPressed: () {
                if (accountNumberController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {

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
