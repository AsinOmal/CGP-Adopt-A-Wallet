import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  final bool isSettingPin;
  final Function(String)? onPinSet;
  final Function? onSuccess;
  final String? savedPin;

  const PinScreen({super.key, this.isSettingPin = false, this.onPinSet, this.onSuccess, this.savedPin});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _confirmPin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSettingPin ? 'Set PIN' : 'Enter PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
            ),
            if (widget.isSettingPin && _confirmPin == null)
              const Text('Re-enter PIN to confirm'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.isSettingPin) {
                  if (_confirmPin == null) {
                    setState(() {
                      _confirmPin = _pinController.text;
                      _pinController.clear();
                    });
                  } else if (_confirmPin == _pinController.text) {
                    widget.onPinSet?.call(_pinController.text);
                  }
                } else if (_pinController.text == widget.savedPin) {
                  widget.onSuccess?.call();
                }
              },
              child: Text(widget.isSettingPin ? 'Set PIN' : 'Enter'),
            ),
          ],
        ),
      ),
    );
  }
}
