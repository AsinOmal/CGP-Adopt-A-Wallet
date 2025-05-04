import 'package:flutter/material.dart';

class ChoiceBox extends StatefulWidget {
  const ChoiceBox({super.key});

  @override
  State<ChoiceBox> createState() => _ChoiceBoxState();
}

class _ChoiceBoxState extends State<ChoiceBox> {
  String? _selectedItem = 'Daily';

  final List<String> _items = ['Daily', 'Weekly', 'Monthly'];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceDim,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            elevation: 2,
            style: const TextStyle(
              color: Color.fromARGB(255, 126, 125, 125),
            ),
            value: _selectedItem,
            items: _items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedItem = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
