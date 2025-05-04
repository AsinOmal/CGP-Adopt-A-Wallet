part of 'reminder_bloc.dart';

sealed class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object> get props => [];
}

final class ReminderInitial extends ReminderState {}

final class ReminderLoading extends ReminderState {}

final class ReminderSuccess extends ReminderState {}

final class ReminderUpdateSuccess extends ReminderState {}

final class ReminderUpdateLoading extends ReminderState {}

final class ReminderFetchLoading extends ReminderState {}

final class ReminderLoaded extends ReminderState {
  final List<Reminder> reminders;

  const ReminderLoaded({required this.reminders});
  @override
  List<Object> get props => [reminders];
}

final class ReminderEmpty extends ReminderState {}

final class ReminderError extends ReminderState {
  final String message;

  const ReminderError({required this.message});
}

final class ReminderUpdateError extends ReminderState {
  final String message;
  const ReminderUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

final class ReminderDeleteError extends ReminderState {
  final String message;
  const ReminderDeleteError({required this.message});

  @override
  List<Object> get props => [message];
}
