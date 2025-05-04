import 'dart:math';
import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/glass_effect_icon.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class BalanaceCard extends StatefulWidget {
  const BalanaceCard({super.key});

  @override
  State<BalanaceCard> createState() => _BalanaceCardState();
}

class _BalanaceCardState extends State<BalanaceCard> {
  late TransactionBloc _transactionBloc;
  late AuthRepository _authRepository;
  double totalBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  final List<String> visaCardImages = [
    'assets/images/visacard1.png',
    'assets/images/visacard3.png',
    'assets/images/mastercard1.png',
    'assets/images/mastercard2.png',
    'assets/images/mastercard3.png',
  ];

  @override
  void initState() {
    super.initState();
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _transactionBloc
        .add(TransactionGetTotalsEvent(userID: _authRepository.userID));
  }

  String getRandomVisaCardImage() {
    final random = Random();
    return visaCardImages[random.nextInt(visaCardImages.length)];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) {
        return current is TransactionSuccess ||
            current is TrnsactionUpdateSuccess ||
            current is TransactionDeleteSuccess;
      },
      listener: (context, state) {
        _transactionBloc
            .add(TransactionGetTotalsEvent(userID: _authRepository.userID));
      },
      child: Stack(
        children: [
          Image.asset(
            getRandomVisaCardImage(),
            height: 210,
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)
                              .translate('total_balance'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Color.fromARGB(206, 255, 255, 255),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                BlocBuilder<TransactionBloc, TransactionState>(
                  buildWhen: (previous, current) {
                    return current is TransactionGetTotalLoading ||
                        current is TransactionGetTotalLoaded ||
                        current is TransactionGetTotalError;
                  },
                  builder: (context, state) {
                    if (state is TransactionGetTotalLoaded) {
                      totalBalance =
                          (state.totalIncomeExpense['totalIncome'] ?? 0.0) -
                              (state.totalIncomeExpense['totalExpense'] ?? 0.0);
                      return Text(
                        'LKR ${totalBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else if (state is TransactionGetTotalLoading) {
                      return Lottie.asset(
                        'assets/animations/text-animation.json',
                        height: 25,
                      );
                    }
                    return Lottie.asset(
                      'assets/animations/text-animation.json',
                      height: 25,
                    );
                  },
                ),
                const SizedBox(height: 45),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const GlassEffectIcon(icon: Icons.arrow_downward),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context).translate('income'),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const GlassEffectIcon(icon: Icons.arrow_upward),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context).translate('expenses'),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlocBuilder<TransactionBloc, TransactionState>(
                      buildWhen: (previous, current) {
                        return current is TransactionGetTotalLoading ||
                            current is TransactionGetTotalLoaded ||
                            current is TransactionGetTotalError;
                      },
                      builder: (context, state) {
                        if (state is TransactionGetTotalLoaded) {
                          totalIncome =
                              state.totalIncomeExpense['totalIncome'] ?? 0.0;
                          return Text(
                            'LKR ${totalIncome.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (state is TransactionGetTotalLoading) {
                          return Lottie.asset(
                            'assets/animations/text-animation.json',
                            height: 25,
                          );
                        }
                        return Lottie.asset(
                          'assets/animations/text-animation.json',
                          height: 25,
                        );
                      },
                    ),
                    BlocBuilder<TransactionBloc, TransactionState>(
                      buildWhen: (previous, current) {
                        return current is TransactionGetTotalLoading ||
                            current is TransactionGetTotalLoaded ||
                            current is TransactionGetTotalError;
                      },
                      builder: (context, state) {
                        if (state is TransactionGetTotalLoaded) {
                          totalExpense =
                              state.totalIncomeExpense['totalExpense'] ?? 0.0;

                          return Text(
                            'LKR ${totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (state is TransactionGetTotalLoading) {
                          return Lottie.asset(
                            'assets/animations/text-animation.json',
                            height: 25,
                          );
                        }
                        return Lottie.asset(
                          'assets/animations/text-animation.json',
                          height: 25,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
