import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/screens/payment-pages/types_of_bill/qr_payment/scan_datails_page.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'dart:developer' as dev;

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  bool isFlashOn = false;
  bool isFrontCamera = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();
  String? shopName;
  String? accNumber;
  String? address;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _parseQRCodeData(String code) {
    shopName = null;
    accNumber = null;
    address = null;

    // Split and clean up the text
    final List<String> pairs = code.trim().split(';');
    dev.log('Pairs: $pairs');

    for (var pair in pairs) {
      // Split each pair by ':' to separate the key and value
      final List<String> keyValue = pair.split(':');
      if (keyValue.length == 2) {
        final String key = keyValue[0].trim().toLowerCase();
        final String value = keyValue[1].trim().replaceAll(RegExp(r',$'), '');

        // Log parsed data
        dev.log('Key: $key, Value: $value');

        // Map the keys to their respective text fields
        if (key == 'shopname') {
          shopName = value;
        } else if (key == 'accnumber') {
          accNumber = value;
        } else if (key == 'address') {
          address = value;
        }
      }
    }

    // Validate the required keys
    if (shopName != null && accNumber != null && address != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanDetailsPage(
            shopName: shopName!,
            accNumber: accNumber!,
            address: address!,
          ),
        ),
      ).then((_) {
        // Restart the camera when returning to this page
        setState(() {
          isScanCompleted = false;
        });
        cameraController.start();
      });
    } else {
      // Show error dialog if the required data is missing
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid QR Code"),
          content: const Text(
              "The scanned QR code does not contain valid information. Please try again."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  isScanCompleted = false; // Allow another scan
                });
                cameraController.start();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void handleQRCodeDetection(String code) {
    if (!isScanCompleted) {
      setState(() {
        isScanCompleted = true;
      });
      cameraController.stop(); // Stop the camera
      _parseQRCodeData(code); // Parse and handle QR code data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            allowDuplicates: true,
            onDetect: (barcode, args) {
              final String code = barcode.rawValue ?? "";
              handleQRCodeDetection(code);
            },
          ),
          QRScannerOverlay(
            overlayColor: Colors.black26,
            borderColor: const Color(0xFF456EFE),
            borderStrokeWidth: 5,
            borderRadius: 12,
          ),
          Align(
            alignment: const AlignmentDirectional(0.95, -.9),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isFlashOn = !isFlashOn;
                });
                cameraController.toggleTorch();
              },
              icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(-0.9, -0.9),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0.65, -.9),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isFrontCamera = !isFrontCamera;
                });
                cameraController.switchCamera();
              },
              icon: const Icon(
                Icons.flip_camera_android,
              ),
            ),
          ),
           Align(
            alignment: const AlignmentDirectional(0, -0.7),
            child: Text(
              AppLocalizations.of(context).translate('scan_shop_qr'),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
