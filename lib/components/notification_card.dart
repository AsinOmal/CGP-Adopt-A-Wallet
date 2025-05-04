import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
  });

  final Map<String, dynamic> notification; // Change type to dynamic

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: notification['isRead']
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.surfaceDim,
      child: ListTile(
        title: Text(
          notification['title']!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(notification['description']!),
        trailing: Text(
          notification['date']!,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
