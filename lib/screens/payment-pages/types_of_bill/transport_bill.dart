import 'package:financial_app/components/simple_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/input_field.dart';
// For date formatting

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController travelDateController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    paymentDateController.text =
        DateFormat('MM/dd/yyyy').format(DateTime.now());
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
        title: const Center(
          child: Text(
            'Transport Payment',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.directions_bus, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter Your Transport Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            InputField(
              isObsecure: false,
              controller: fromController,
              isReadOnly: false,
              prefixIcon: Icons.location_on,
              keyboardType: TextInputType.text,
              label: 'From',
            ),
            const SizedBox(height: 16),
            InputField(
              isObsecure: false,
              controller: toController,
              isReadOnly: false,
              prefixIcon: Icons.location_on,
              keyboardType: TextInputType.text,
              label: 'To',
            ),
            const SizedBox(height: 16),
            InputField(
              isReadOnly: false,
              isObsecure: false,
              prefixIcon: Icons.money,
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
            const SizedBox(height: 16),
            InputField(
              isReadOnly: true,
              isObsecure: false,
              label: 'Travel Date',
              prefixIcon: Icons.calendar_today,
              suffixIcon: IconButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    travelDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                icon: const Icon(Icons.edit),
              ),
              controller: travelDateController,
            ),
            const SizedBox(height: 16),
            InputField(
              isReadOnly: true,
              isObsecure: false,
              label: 'Date of Payment',
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
            const SizedBox(height: 16),
            SimpleButton(
              data: 'Pay Bill',
              onPressed: () {
                if (fromController.text.isNotEmpty &&
                    toController.text.isNotEmpty &&
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
