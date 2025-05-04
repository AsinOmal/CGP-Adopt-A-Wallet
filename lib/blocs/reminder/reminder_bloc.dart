import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_app/models/reminder.dart';
import 'package:financial_app/repositories/reminder/reminder_repository.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _reminderRepository;

  ReminderBloc(this._reminderRepository) : super(ReminderInitial()) {
    on<ReminderEvent>((event, emit) async {
      if (event is ReminderAddEvent) {
        try {
          emit(ReminderLoading());
          await _reminderRepository.addReminder(reminder: event.reminder);
          emit(ReminderSuccess());
        } catch (e) {
          emit(ReminderError(message: e.toString()));
        }
      }
      if (event is ReminderFetchEvent) {
        try {
          emit(ReminderFetchLoading());
          final reminders =
              await _reminderRepository.getReminders(userID: event.userID);
          if (reminders.isNotEmpty) {
            emit(ReminderLoaded(reminders: reminders));
          } else {
            emit(ReminderEmpty());
          }
        } catch (e) {
          emit(ReminderError(
              message: 'Error during fetching from database${e.toString()}'));
        }
      }
      if (event is ReminderUpdateEvent) {
        try {
          emit(ReminderUpdateLoading());
          await _reminderRepository.updateReminder(
              reminderID: event.reminderID, reminder: event.reminder);
          await Future.delayed(const Duration(milliseconds: 500));
          emit(ReminderUpdateSuccess());
        } catch (e) {
          await Future.delayed(const Duration(milliseconds: 500));
          emit(
            const ReminderUpdateError(message: 'Error during updating'),
          );
        }
      }
      if (event is ReminderDeleteEvent) {
        try {
          await _reminderRepository.deleteReminder(
              reminderID: event.reminderID);
        } catch (e) {
          emit(const ReminderDeleteError(message: 'Error during deleting'));
        }
      }
    });
  }
}
