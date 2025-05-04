import 'package:financial_app/blocs/card/card_bloc.dart';
import 'package:financial_app/components/payment_option.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/payment-pages/payment_methord/card_payment_screen.dart';
import 'package:financial_app/services/transaction_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PaymentMethodSheet extends StatefulWidget {
  final double amount;
  final TransactionType type;
  final String billingNumber;

  const PaymentMethodSheet({
    super.key,
    required this.amount,
    required this.type,
    required this.billingNumber,
  });

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  late CardBloc _cardBloc;
  late AuthRepository _authRepository;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _cardBloc = RepositoryProvider.of<CardBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);

    // Fetch user's cards
    _cardBloc.add(CardFetchEvent(userID: _authRepository.userID));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 550,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Choose payment method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<CardBloc, CardState>(
                builder: (context, state) {
                  if (state is CardFetchLoading) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    );
                  } else if (state is CardFetchLoaded) {
                    if (state.cards.isEmpty) {
                      return const Center(
                        child: Text('No saved cards. Please add a card.'),
                      );
                    }
                    return SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: state.cards.length,
                        itemBuilder: (context, index) {
                          final card = state.cards[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: PaymentOption(
                              isSelected: _selectedIndex == index,
                              name: card.cardholderName,
                              number: card.cardNumber,
                              isVisa: card.isVisa,
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const Center(
                    child: Text('Failed to load cards.'),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardPaymentScreen(
                      accountNumber: widget.billingNumber,
                      amount: widget.amount,
                      type: widget.type,
                    ),
                  ),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 5),
                  Text(
                    'Add new card',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFe3f7ef),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.justify,
                        'We adhere entirely to the data security standards of the payment card industry.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SimpleButton(
              data: 'Continue',
              onPressed: _selectedIndex >= 0
                  ? () {
                      Navigator.pop(context, true);
                    }
                  : null, // Disable button if no card is selected
            ),
          ],
        ),
      ),
    );
  }
}
