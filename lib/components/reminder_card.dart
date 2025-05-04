import 'package:financial_app/components/reminder_update_popup.dart';
import 'package:financial_app/models/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ReminderCard extends StatefulWidget {
  final Reminder reminder;
  final void Function(BuildContext)? deleteFunction;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.deleteFunction,
  });

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard>
    with SingleTickerProviderStateMixin {
  double _borderRadius = 15.0;
  late final SlidableController _slidableController;
  late String title;
  late String description;
  late String date;
  late String time;
  late String frequancy;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
    _slidableController.animation.addListener(() {
      if (_slidableController.animation.value > 0) {
        setState(() {
          _borderRadius = 0.0;
        });
      } else {
        setState(() {
          _borderRadius = 15.0;
        });
      }
    });
    title = widget.reminder.title;
    description = widget.reminder.description;
    date = widget.reminder.date;
    time = widget.reminder.time;
    frequancy = widget.reminder.frequancy;
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 35,
        right: 20,
        bottom: 20,
      ),
      child: Slidable(
        controller: _slidableController,
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: widget.deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade400,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(179, 69, 109, 254),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                Text(
                  DateFormat('dd').format(DateTime.parse(date)),
                  style: const TextStyle(fontSize: 20),
                ),
                Text(DateFormat('EEE')
                    .format(DateTime.parse(date))
                    .toUpperCase()),
              ],
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15),
                    bottomLeft: const Radius.circular(15),
                    topRight: Radius.circular(_borderRadius),
                    bottomRight: Radius.circular(_borderRadius),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title.length > 10 ? title.substring(0, 10) : title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              final updatedreminder =
                                  await showModalBottomSheet<Reminder>(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return ReminderUpdatePopup(
                                    reminder: Reminder(
                                        userID: widget.reminder.userID,
                                        createdAt: widget.reminder.createdAt,
                                        id: widget.reminder.id,
                                        date: date,
                                        description: description,
                                        frequancy: frequancy,
                                        time: time,
                                        title: title),
                                  );
                                },
                              );
                              if (updatedreminder != null) {
                                setState(() {
                                  title = updatedreminder.title;
                                  description = updatedreminder.description;
                                  date = updatedreminder.date;
                                  time = updatedreminder.time;
                                  frequancy = updatedreminder.frequancy;
                                });
                              }
                            },
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            time,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            frequancy,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
