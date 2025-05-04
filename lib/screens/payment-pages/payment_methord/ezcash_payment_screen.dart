// import 'package:flutter/material.dart';

// import '../payment_success_screen.dart';

// class EzCashPaymentScreen extends StatelessWidget {
//   final String accountNumber;
//   final String amount;

//   const EzCashPaymentScreen(
//       {super.key, required this.accountNumber, required this.amount});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         title: const Center(
//           child: Text(
//             'eZ Cash Payment',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Enter eZ Cash Details',
//               style: TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 16),
//             // Add your eZ Cash fields here (e.g. eZ Cash Number)
//             // For simplicity, I am skipping detailed fields for this example
//             const TextField(
//               decoration: InputDecoration(
//                 labelText: 'eZ Cash Number',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to payment success screen
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => PaymentSuccessScreen(
//                           accountNumber: accountNumber, amount: amount)),
//                 );
//               },
//               child: const Text('Pay with eZ Cash'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
