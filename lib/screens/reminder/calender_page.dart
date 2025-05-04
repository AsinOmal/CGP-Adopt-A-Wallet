import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/screens/reminder/add_reminder.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financial_app/blocs/reminder/reminder_bloc.dart';
import 'package:financial_app/models/reminder.dart';

class CalendarReminderPage extends StatefulWidget {
  const CalendarReminderPage({super.key});

  @override
  State<CalendarReminderPage> createState() => _CalendarReminderPageState();
}

class _CalendarReminderPageState extends State<CalendarReminderPage> {
  late AuthRepository _authRepository;
  late ReminderBloc _reminderBloc;
  late EventController _eventController;

  @override
  void initState() {
    super.initState();
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _reminderBloc = RepositoryProvider.of<ReminderBloc>(context);
    _eventController = EventController();
    _reminderBloc.add(ReminderFetchEvent(userID: _authRepository.userID));
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  void _loadRemindersAsEvents(List<Reminder> reminders) {
    _eventController.removeWhere((event) => true);

    for (var reminder in reminders) {
      final eventDate = DateTime.parse(reminder.date);
      _eventController.add(CalendarEventData(
        date: eventDate,
        title: reminder.title,
        description: reminder.description,
        event: reminder,
      ));
    }
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
          AppLocalizations.of(context).translate('calender'),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        bloc: _reminderBloc,
        buildWhen: (previous, current) =>
            current is ReminderFetchLoading || current is ReminderLoaded,
        builder: (context, state) {
          if (state is ReminderFetchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReminderLoaded) {
            _loadRemindersAsEvents(state.reminders);
            return CalendarControllerProvider(
              controller: _eventController,
              child: MonthView(
                onCellTap: (events, date) {
                  if (events.isNotEmpty) {
                    _showRemindersDialog(events);
                  }
                },
                cellBuilder: (date, events, isToday, isInMonth, isSelected) {
                  bool hasReminders = events.isNotEmpty;

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: hasReminders
                          ? Colors.blueAccent.withOpacity(0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: hasReminders
                                ? Colors.blueAccent
                                : const Color.fromARGB(255, 79, 78, 78),
                            fontWeight: hasReminders
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (hasReminders)
                          const Icon(Icons.circle, color: Colors.red, size: 5),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('no_reminders_found'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddReminder(),
            ),
          );
        },
        backgroundColor: const Color(0xFF456EFE),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showRemindersDialog(List<CalendarEventData> events) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('your_reminders')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: events.map((event) {
              return ListTile(
                title: Text(event.title),
                subtitle: Text(event.description ?? ''),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).translate('close'),),
            ),
          ],
        );
      },
    );
  }
}
