part of 'reminder_bloc.dart';

sealed class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object> get props => [];
}

class ReminderAddEvent extends ReminderEvent {
  final Reminder reminder;

  const ReminderAddEvent({required this.reminder});

  @override
  List<Object> get props => [reminder];
}

class ReminderFetchEvent extends ReminderEvent {
  final String userID;
  const ReminderFetchEvent({required this.userID});

  @override
  List<Object> get props => [userID];
}

class ReminderUpdateEvent extends ReminderEvent {
  final String reminderID;
  final Reminder reminder;
  const ReminderUpdateEvent({required this.reminderID, required this.reminder});

  @override
  List<Object> get props => [reminderID, reminder];
}

class ReminderDeleteEvent extends ReminderEvent {
  final String reminderID;
  const ReminderDeleteEvent({required this.reminderID});

  @override
  List<Object> get props => [reminderID];
}
