import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/services_icon.dart';
import 'package:financial_app/components/balance_card.dart';
import 'package:financial_app/components/transaction_tile.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/analysis/analysis_page.dart';
import 'package:financial_app/screens/budget/budget_page.dart';
import 'package:financial_app/screens/goals/goal_page.dart';
import 'package:financial_app/screens/reminder/reminder_page.dart';
import 'package:financial_app/screens/transactions/transactions_page.dart';
import 'package:financial_app/services/sms_service.dart';
import 'package:financial_app/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon 🌞';
    } else if (hour < 20) {
      return 'Good Evening 🌅';
    } else {
      return 'Good Night 🌔';
    }
  }

  String? name;
  late TransactionBloc _transactionBloc;
  late AuthBloc _authBloc;
  late AuthRepository _authRepository;
  late SmsService _smsService;

  Future<bool> getBoolValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool('isTransactionEnabled') ?? false;
    return value;
  }

  Future<void> _initializeSmsService() async {
    bool isTransactionEnabled = await getBoolValue(); // Await the Future
    _smsService.toggleListen(isTransactionEnabled); // Now pass the bool value
    if (isTransactionEnabled) {
      _smsService.getMessages();
    }
  }

  @override
  void initState() {
    super.initState();
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _authBloc = RepositoryProvider.of<AuthBloc>(context);
    _authBloc.add(AuthInfoFetching(userID: _authRepository.userID));
    _transactionBloc.add(TransactionFetchEvent(userID: _authRepository.userID));
    _smsService = Provider.of<SmsService>(context, listen: false);
    _initializeSmsService();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     Expanded(
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Stack(
            //             children: [
            // Lottie.asset(
            //   'assets/animations/dashboard_animation.json',
            //   width: 120,
            // ),
            //             ],
            //           ),
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(getGreeting()),
            // BlocBuilder<AuthBloc, AuthState>(
            //   buildWhen: (previous, current) {
            //     return current is AuthInfoLoading ||
            //         current is AuthInfoSuccess ||
            //         current is AuthInfoError;
            //   },
            //   builder: (context, state) {
            //     if (state is AuthInfoSuccess) {
            // return SizedBox(
            //     width:
            //         MediaQuery.of(context).size.width / 3,
            //     child: state.user.name
            //                 .substring(
            //                     0,
            //                     state.user.name
            //                         .indexOf(' '))
            //                 .length >=
            //             10
            //         ? Marquee(
            //             text: state.user.name.substring(0,
            //                 state.user.name.indexOf(' ')),
            //             style: const TextStyle(
            //                 letterSpacing: 2,
            //                 fontSize: 25,
            //                 fontWeight: FontWeight.bold),
            //             velocity: 30.0,
            //             pauseAfterRound:
            //                 const Duration(seconds: 2),
            //             blankSpace: 30.0,
            //           )
            //         : Text(
            //             state.user.name.substring(0,
            //                 state.user.name.indexOf(' ')),
            //             style: const TextStyle(
            //               letterSpacing: 2,
            //               fontSize: 25,
            //               fontWeight: FontWeight.bold,
            //             )));
            //     } else if (state is AuthInfoLoading) {
            //       if (isDarkMode) {
            //         return Lottie.asset(
            //           'assets/animations/text-animation.json',
            //           height: 25,
            //         );
            //       } else {
            //         return Lottie.asset(
            //           'assets/animations/text-animation-black.json',
            //           height: 25,
            //         );
            //       }
            //     }
            //     return const Text(
            //       'Welcome',
            //       style: TextStyle(
            //         letterSpacing: 2,
            //         fontSize: 25,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     );
            //   },
            // ),
            //               const Text(''),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //     Column(
            //       children: [
            //         GestureDetector(
            //           onTap: () {
            //             Navigator.push(
            //                 context,
            //                 PageTransition(
            //                     child: const NotificationPage(),
            //                     duration: const Duration(milliseconds: 400),
            //                     reverseDuration:
            //                         const Duration(milliseconds: 400),
            //                     curve: Curves.elasticIn,
            //                     opaque: true,
            //                     type: PageTransitionType.rightToLeft));
            //           },
            //           child: const Icon(
            //             Icons.notifications,
            //             size: 30,
            //           ),
            //         ),
            //         const Text(''),
            //         const Text(''),
            //         const Text(''),
            //       ],
            //     )
            //   ],
            // ),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                ),
                Lottie.asset(
                  'assets/animations/dashboard_animation.json',
                  width: 120,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getGreeting(),
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) {
                        return current is AuthInfoLoading ||
                            current is AuthInfoSuccess ||
                            current is AuthInfoError;
                      },
                      builder: (context, state) {
                        if (state is AuthInfoSuccess) {
                          return SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: state.user.name.split(" ")[0].length >= 10
                                  ? Marquee(
                                      text: state.user.name.split(" ")[0],
                                      style: const TextStyle(
                                          letterSpacing: 2,
                                          fontSize: 25,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                      velocity: 30.0,
                                      pauseAfterRound:
                                          const Duration(seconds: 2),
                                      blankSpace: 30.0,
                                    )
                                  : Text(state.user.name.split(" ")[0],
                                      style: const TextStyle(
                                        letterSpacing: 2,
                                        color: Colors.grey,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      )));
                        } else if (state is AuthInfoLoading) {
                          if (isDarkMode) {
                            return Lottie.asset(
                              'assets/animations/text-animation.json',
                              height: 25,
                            );
                          } else {
                            return Lottie.asset(
                              'assets/animations/text-animation-black.json',
                              height: 25,
                            );
                          }
                        }
                        return const Text(
                          'Welcome',
                          style: TextStyle(
                            letterSpacing: 2,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
            const BalanaceCard(),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).translate('services'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ServicesIcon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const TransactionsPage(),
                            ));
                          },
                          backgroundColor: Colors.blue[100],
                          text: 'transactions',
                          icon: Icons.monetization_on_outlined,
                          foregroundColor: Colors.blue,
                        ),
                        ServicesIcon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const AnalysisPage(),
                            ));
                          },
                          backgroundColor:
                              const Color.fromARGB(255, 251, 187, 251),
                          text: 'reports',
                          icon: Icons.file_copy_outlined,
                          foregroundColor:
                              const Color.fromARGB(255, 255, 98, 255),
                        ),
                        ServicesIcon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ReminderPage(),
                            ));
                          },
                          backgroundColor:
                              const Color.fromARGB(255, 251, 218, 187),
                          text: 'reminders',
                          icon: Icons.alarm,
                          foregroundColor:
                              const Color.fromARGB(255, 253, 159, 71),
                        ),
                        ServicesIcon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const GoalPage(),
                            ));
                          },
                          backgroundColor:
                              const Color.fromARGB(255, 187, 251, 190),
                          text: 'goals',
                          icon: Icons.stairs_outlined,
                          foregroundColor:
                              const Color.fromARGB(255, 56, 250, 66),
                        ),
                        ServicesIcon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const BudgetPage(),
                            ));
                          },
                          backgroundColor:
                              const Color.fromARGB(255, 246, 187, 251),
                          text: 'budget',
                          icon: Icons.account_balance_wallet,
                          foregroundColor:
                              const Color.fromARGB(255, 146, 56, 250),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('recent_history'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                bloc: _transactionBloc,
                buildWhen: (previous, current) {
                  return current is TransactionFetchLoading ||
                      current is TransactionLoaded ||
                      current is TransactionError ||
                      current is TransactionEmpty;
                },
                builder: (context, state) {
                  if (state is TransactionFetchLoading) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.grey,
                        size: 50.0,
                      ),
                    );
                  } else if (state is TransactionLoaded) {
                    return ListView.builder(
                      itemCount: state.transactions.length > 6
                          ? 6
                          : state.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        return TransactionTile(
                          transaction: transaction,
                          deleteFunction: (p0) async {
                            _transactionBloc.add(
                              TransactionDeleteEvent(
                                transactionID: transaction.id,
                              ),
                            );
                            _transactionBloc.add(TransactionFetchEvent(
                                userID: _authRepository.userID));

                            showSuccessSnakBar();
                          },
                        );
                      },
                    );
                  } else if (state is TransactionEmpty) {
                    return Center(
                        child: Text(
                      AppLocalizations.of(context)
                          .translate('no_transactions_found'),
                    ));
                  }
                  return Center(
                      child: Text(
                    AppLocalizations.of(context)
                        .translate('no_transactions_found'),
                  ));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: 'Deleted!!',
      message: AppLocalizations.of(context)
          .translate('transaction_deleted_successfully'),
      contentType: ContentType.success,
    );
  }
}
