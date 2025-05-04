import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as dev;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    // Handle different actions based on the actionId
    if (notificationResponse.actionId == 'complete_action') {
      dev.log('Notification marked as complete.');
      await flutterLocalNotificationsPlugin.cancel(notificationResponse.id!);
    } else if (notificationResponse.actionId == 'snooze_action') {
      dev.log('Notification snoozed.');
      await snoozeNotification(notificationResponse.id!);
    } else {
      dev.log('Notification received.');
    }
  }

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel', // id
      'Reminder_Channel', // name
      description: 'Channel for instant notifications', // description
      importance: Importance.max,
    );

    final AndroidFlutterLocalNotificationsPlugin androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!;
    await androidPlugin.createNotificationChannel(channel);
  }

  static Future<void> showInstantNotification(String title, String body) async {
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notification_channel_id',
        'Instant Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        actions: [
          AndroidNotificationAction('complete_action', 'Complete'),
          AndroidNotificationAction('snooze_action', 'Snooze'),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true, // Play the default iOS notification sound
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'instant_notification',
    );
  }

  static Future<void> scheduleNotification(int id, String title, String body,
      DateTime scheduledTime, String frequency) async {
    // Define notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminder_Channel',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        actions: [
          AndroidNotificationAction('complete_action', 'Complete'),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime firstNotificationTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    if (firstNotificationTime.isBefore(now)) {
      firstNotificationTime =
          firstNotificationTime.add(const Duration(days: 1));
    }

    if (frequency == 'Every minute') {
      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.everyMinute,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else if (frequency == 'Everyday') {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        firstNotificationTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (frequency == 'Every week') {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        firstNotificationTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } else if (frequency == 'Every month') {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        firstNotificationTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        firstNotificationTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> snoozeNotification(int id) async {
    // Snooze logic (e.g., 5 minutes from now)
    final snoozeTime =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5));
    await scheduleNotification(
        id, 'Reminder', 'Snoozed notification', snoozeTime, 'never');
  }

  static void cancelReminderNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
