import 'package:financial_app/components/notification_card.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Bill Reminder',
      'description': 'Your electricity bill is due on 25th October.',
      'date': 'Today',
      'isRead': false,
    },
    {
      'title': 'Goal Update',
      'description': 'You are 80% close to reaching your savings goal.',
      'date': 'Yesterday',
      'isRead': true,
    },
    {
      'title': 'Goal Update',
      'description': 'You are 80% close to reaching your savings goal.',
      'date': 'Yesterday',
      'isRead': false,
    },
    {
      'title': 'Goal Update',
      'description': 'You are 80% close to reaching your savings goal.',
      'date': 'Yesterday',
      'isRead': false,
    },
    {
      'title': 'Goal Update',
      'description': 'You are 80% close to reaching your savings goal.',
      'date': 'Yesterday',
      'isRead': false,
    },
    {
      'title': 'Goal Update',
      'description': 'You are 80% close to reaching your savings goal.',
      'date': 'Yesterday',
      'isRead': false,
    },
  ];

  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true; // Update the isRead property
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title:  Text(
          AppLocalizations.of(context).translate('notifications'),
          style: const TextStyle(fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: markAllAsRead, // Call markAllAsRead on press
                  child: Text(
                    AppLocalizations.of(context).translate('mark_as_read'),
                    style: const TextStyle(
                      color: Color(0xFF456EFE),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return NotificationCard(
                    notification: notifications[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
