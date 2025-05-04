import 'package:financial_app/models/reminder.dart';

abstract class BaseReminderRepository {
  Future<void> addReminder({required Reminder reminder});

  Future<List<Reminder>> getReminders({required String userID});

  Future<void> deleteReminder({required String reminderID});

  Future<void> updateReminder(
      {required String reminderID, required Reminder reminder});

  Future<void> scheduleReminderNotification({required Reminder reminder});
}
