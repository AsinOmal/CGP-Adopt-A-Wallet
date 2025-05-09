import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:financial_app/blocs/auth/auth_bloc.dart';
import 'package:financial_app/data/keys.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/navigators/navigation_keys.dart';
import 'package:financial_app/screens/dashboard/dashboard_page.dart';
import 'package:financial_app/screens/notification/notification_page.dart';
// import 'package:financial_app/screens/payment-pages/bill_payment_page.dart';
import 'package:financial_app/screens/profile-pages/account_info/account_info_page.dart';
import 'package:financial_app/screens/profile-pages/privacy_policy/privacy_policy_page.dart';
import 'package:financial_app/screens/cards/cards_page.dart';
import 'package:financial_app/screens/profile-pages/rating/rating_dialog.dart';
import 'package:financial_app/screens/profile-pages/settings/settings_page.dart';
import 'package:financial_app/screens/shared-expenses/create_a_group.dart';
import 'package:financial_app/screens/shared-expenses/shared_expenses_first_page.dart';
import 'package:financial_app/screens/transactions/transaction_type_page.dart';
import 'package:financial_app/services/feedback_repository.dart';
import 'package:financial_app/services/profile_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:transitioned_indexed_stack/transitioned_indexed_stack.dart';
import 'dart:developer' as dev;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final String _notification = 'assets/icons/notificationregular.ico';
  final String _notificationfilled = 'assets/icons/notificationfilled.ico';
  final String _group = 'assets/icons/groupoutlined.ico';
  final String _groupfilled = 'assets/icons/groupfilled.ico';
  //final String _payment = 'assets/icons/payment.ico';
  //final String _paymentOut = 'assets/icons/payment_out.ico';
  final String _visaOut = 'assets/icons/visa.ico';
  final String _visa = 'assets/icons/visa_fill.ico';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _url;

  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = RepositoryProvider.of<AuthBloc>(context);
    loadProfileImage();
  }

  Future<void> loadProfileImage() async {
    final url = await ProfileImageService().getImageUrl();
    setState(() {
      _url = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is AuthSignOut ||
            current is AuthLoading ||
            current is AuthProfileImageUpdateSuccess;
      },
      listener: (context, state) {
        if (state is AuthSignOut) {
          Navigator.pop(context);
          globalNavigatorKey.currentState!.pushReplacementNamed('/login');
        } else if (state is AuthLoading) {
          showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: SpinKitThreeBounce(
                  color: Colors.white,
                  size: 50.0,
                ),
              );
            },
          );
        } else if (state is AuthProfileImageUpdateSuccess) {
          setState(() {
            _url = state.url;
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                child: CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(_url ??
                      'https://wlujgctqyxyyegjttlce.supabase.co/storage/v1/object/public/users_propics/users_propics/default_img.png'),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('account_info'),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AccountInfoScreen(),
                          ));
                        },
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('privacy_policy'),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            AppLocalizations.of(context).translate('settings'),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.feedback),
                        title: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            AppLocalizations.of(context).translate('feedback'),
                          ),
                        ),
                        onTap: () {
                          BetterFeedback.of(context)
                              .show((UserFeedback feedback) async {
                            BetterFeedback.of(context).hide();
                            try {
                              final screenshotFilePath =
                                  await writeImageToStorage(
                                      feedback.screenshot);

                              final smtpServer = gmail(username, password);

                              final message = Message()
                                ..from =
                                    const Address(username, 'Adopt A Wallet')
                                ..recipients
                                    .add('adoptawallet.devnet.error@gmail.com')
                                ..subject = 'App Feedback'
                                ..text = feedback.text
                                ..attachments = [
                                  FileAttachment(File(screenshotFilePath))
                                ];

                              final sendReport =
                                  await send(message, smtpServer);
                              dev.log(
                                  'Feedback Email sent: ${sendReport.toString()}');
                            } on MailerException catch (e) {
                              dev.log(
                                  'Failed to send feedback email: ${e.toString()}');
                              for (var p in e.problems) {
                                dev.log('Problem: ${p.code}: ${p.msg}');
                              }
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.star_rate),
                        title: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            AppLocalizations.of(context).translate('rate_app'),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RatingDialog(),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      ListTile(
                        leading: const Icon(Icons.power_settings_new),
                        onTap: () {
                          Navigator.of(context).pop();
                          _authBloc.add(AuthSignOutRequest());
                        },
                        title: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            AppLocalizations.of(context).translate('logout'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        body: Stack(
          children: [
            FadeIndexedStack(
              index: _currentIndex,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 200),
              children: const [
                Dashboard(),
                CardsPage(),
                // Wrap SharedExpensePage with HeroMode to disable Hero animations
                HeroMode(enabled: false, child: SharedExpensePage()),
                NotificationPage(),
              ],
            ),
            Align(
              alignment: const AlignmentDirectional(-0.90, -0.88),
              child: GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20.0,
                    backgroundColor: const Color.fromARGB(255, 226, 226, 226),
                    backgroundImage: NetworkImage(
                      _url ??
                          dotenv.env['DEFAULT_IMAGE_URL'] ??
                          'https://nlekhbkoqtatppkfocoo.supabase.co/storage/v1/object/public/users-propics//default_img.png',
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: _currentIndex == 0 || _currentIndex == 2
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddGroupScreen(),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF456EFE),
                shape: const CircleBorder(),
                elevation: 0,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              )
            : null,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).bottomAppBarTheme.color,
          height: 60,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                left: 20,
                top: 0.0,
                bottom: 0.0,
                child: IconButton(
                  icon: Icon(
                    _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                left: _currentIndex == 0 ? 100.0 : 115.0,
                top: 0.0,
                bottom: 0.0,
                child: IconButton(
                  icon: ImageIcon(
                    AssetImage(
                      _currentIndex == 1 ? _visa : _visaOut,
                    ),
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                right: _currentIndex == 0 ? 100.0 : 115.0,
                top: 0.0,
                bottom: 0.0,
                child: IconButton(
                  icon: ImageIcon(
                    AssetImage(
                      
                      _currentIndex == 2 ? _groupfilled : _group,
                    ),
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                right: 20.0,
                top: 0.0,
                bottom: 0.0,
                child: IconButton(
                  icon: ImageIcon(
                    AssetImage(
                      _currentIndex == 3 ? _notificationfilled : _notification,
                    ),
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget getPageByIndex(int index) {
  switch (index) {
    case 0:
      return const TransactionTypePage();
    case 2:
      return const AddGroupScreen();
    default:
      return const Placeholder();
  }
}
