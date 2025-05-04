import 'package:flutter/material.dart';

class PaymentOption extends StatefulWidget {
  final bool isVisa;
  final String name;
  final String number;
  final bool isSelected;

  const PaymentOption({
    super.key,
    required this.isSelected,
    required this.name,
    required this.number,
    required this.isVisa,
  });

  @override
  State<PaymentOption> createState() => _PaymentOptionState();
}

class _PaymentOptionState extends State<PaymentOption> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Theme.of(context).colorScheme.surfaceDim
              : null,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            leading: Image.asset(
              widget.isVisa
                  ? 'assets/payments/visa_edit.png'
                  : 'assets/payments/master_edit.png',
              width: 80,
            ),
            title: Text(
              widget.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: widget.isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text('**** ${widget.number.substring(15)}'),
            ),
          ),
        ),
      ),
    );
  }
}
