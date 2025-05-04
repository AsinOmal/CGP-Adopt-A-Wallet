import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:financial_app/blocs/reminder/reminder_bloc.dart';
import 'package:financial_app/components/custome_snackbar.dart';
import 'package:financial_app/components/reminder_card.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/reminder/add_reminder.dart';
import 'package:financial_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:month_year_picker/month_year_picker.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('en'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF456EFE), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Theme.of(context)
                  .colorScheme
                  .secondaryFixed, // body text color
              secondary: const Color(0xFF456EFE),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF456EFE), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  late AuthRepository _authRepository;
  late ReminderBloc _reminderBloc;

  @override
  void initState() {
    super.initState();
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _reminderBloc = RepositoryProvider.of<ReminderBloc>(context);
    _reminderBloc.add(ReminderFetchEvent(userID: _authRepository.userID));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF456EFE),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate('your_reminders'),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddReminder(),
              ));
        },
        backgroundColor: const Color(0xFF456EFE),
        shape: const CircleBorder(),
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 70,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              color: Color(0xFF456EFE),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM yyyy').format(selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectMonthYear(context),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('date'),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).translate('event'),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LiquidPullToRefresh(
              color: Theme.of(context).colorScheme.surface,
              backgroundColor: Theme.of(context).colorScheme.primary,
              onRefresh: () async {
                _reminderBloc
                    .add(ReminderFetchEvent(userID: _authRepository.userID));
              },
              child: BlocBuilder<ReminderBloc, ReminderState>(
                bloc: _reminderBloc,
                buildWhen: (previous, current) {
                  return current is ReminderFetchLoading ||
                      current is ReminderEmpty ||
                      current is ReminderLoaded ||
                      current is ReminderError;
                },
                builder: (context, state) {
                  if (state is ReminderFetchLoading) {
                    return const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    );
                  } else if (state is ReminderLoaded) {
                    return ListView.builder(
                      itemCount: state.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = state.reminders[index];
                        return ReminderCard(
                          reminder: reminder,
                          deleteFunction: (context) {
                            _reminderBloc.add(
                                ReminderDeleteEvent(reminderID: reminder.id));
                            _reminderBloc.add(
                              ReminderFetchEvent(
                                  userID: _authRepository.userID),
                            );
                            NotificationService.cancelReminderNotification(
                                reminder.id.hashCode);
                          },
                        );
                      },
                    );
                  } else if (state is ReminderEmpty) {
                    return Center(
                        child: Text(
                      AppLocalizations.of(context)
                          .translate('no_reminders_found'),
                    ));
                  } else if (state is ReminderError) {
                    return Center(child: Text(state.message));
                  }
                  return Center(
                      child: Text(
                    AppLocalizations.of(context)
                        .translate('no_reminders_found'),
                  ));
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void showErrorSnackBar(String error) {
    CustomSnackBar.show(
      context,
      title: 'On Snap!',
      message: AppLocalizations.of(context).translate(error),
      contentType: ContentType.failure,
    );
  }
}
