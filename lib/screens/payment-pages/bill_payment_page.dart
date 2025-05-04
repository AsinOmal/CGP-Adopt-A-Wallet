import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/screens/payment-pages/types_of_bill/electricity_bill.dart';
import 'package:financial_app/screens/payment-pages/types_of_bill/internet_bill.dart';
import 'package:financial_app/screens/payment-pages/types_of_bill/mobile_bill.dart';
import 'package:financial_app/screens/payment-pages/types_of_bill/qr_payment/qr_scanner.dart';
import 'package:financial_app/screens/payment-pages/types_of_bill/tv_bill.dart';
import 'package:financial_app/screens/payment-pages/types_of_bill/water_bill.dart';
import 'package:flutter/material.dart';

class BillPayScreen extends StatelessWidget {
  const BillPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('bill_payment'),
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          crossAxisCount: 2,
          children: [
            OptionCard(
              color: Colors.blue,
              icon: const Icon(Icons.flash_on, size: 50, color: Colors.white),
              title: 'electricity',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ElectricityBillScreen(),
                  ),
                );
              },
            ),
            OptionCard(
              color: Colors.purple,
              icon: const Icon(Icons.wifi, size: 50, color: Colors.white),
              title: 'internet',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InternetBillScreen(),
                  ),
                );
              },
            ),
            OptionCard(
              color: Colors.orangeAccent,
              icon: const Icon(Icons.water, size: 50, color: Colors.white),
              title: 'water',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WaterBillScreen(),
                  ),
                );
              },
            ),
            OptionCard(
              color: Colors.red,
              icon:
                  const Icon(Icons.phone_iphone, size: 50, color: Colors.white),
              title: 'mobile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MobileBillScreen(),
                  ),
                );
              },
            ),
            OptionCard(
              color: Colors.grey,
              icon: const Icon(Icons.tv, size: 50, color: Colors.white),
              title: 'tv',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TvBillScreen(),
                  ),
                );
              },
            ),
            OptionCard(
              color: Colors.cyan,
              icon: const ImageIcon(AssetImage('assets/icons/scan.ico'),
                  size: 50, color: Colors.white),
              title: 'scan_pay',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScanner(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final Color color;
  final String title;
  final VoidCallback onTap;
  final Widget icon;

  const OptionCard(
      {super.key,
      required this.color,
      required this.icon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context).translate(title),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
