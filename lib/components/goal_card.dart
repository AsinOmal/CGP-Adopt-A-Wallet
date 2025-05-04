import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/goal_details_popupcard.dart';
import 'package:financial_app/components/goal_update_popup_card.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/goal.dart';
import 'package:financial_app/services/icon_seletor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class GoalCard extends StatefulWidget {
  final String id;
  final String title;
  final String deadline;
  final double currentAmount;
  final double targetAmount;
  final Timestamp createdAt;
  final void Function(BuildContext)? deleteFunction;

  const GoalCard({
    super.key,
    required this.id,
    required this.title,
    required this.deadline,
    required this.currentAmount,
    required this.targetAmount,
    required this.createdAt,
    required this.deleteFunction,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard>
    with SingleTickerProviderStateMixin {
  double _borderRadius = 15.0; // Default border radius
  late final SlidableController _slidableController;
  late String title;
  late double currentAmount;
  late double targetAmount;
  late String deadline;

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
    title = widget.title;
    currentAmount = widget.currentAmount;
    targetAmount = widget.targetAmount;
    deadline = widget.deadline;
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  bool isGoalComplete() {
    return currentAmount >= targetAmount;
  }

  String getCreatedDate() {
    final DateTime dateTime = widget.createdAt.toDate();
    final String formattedDate = DateFormat('yyyy/MM/dd').format(dateTime);
    return formattedDate;
  }

  String getTimeRemaining() {
    final DateTime today = DateTime.now();
    final DateTime deadlineDateTime = DateTime.parse(deadline);
    final Duration difference = deadlineDateTime.difference(today);
    final int daysRemaining = difference.inDays;

    if (daysRemaining > 30) {
      // Calculate months and remaining days
      final int months = (daysRemaining / 30).floor();
      final int remainingDays = daysRemaining % 30;
      return "$months month${months > 1 ? 's' : ''} and $remainingDays day${remainingDays > 1 ? 's' : ''} left";
    } else if (daysRemaining > 0) {
      return "$daysRemaining day${daysRemaining > 1 ? 's' : ''} left";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} left";
    } else {
      return AppLocalizations.of(context).translate('deadline_passed');
    }
  }

  double getPercentage() {
    double percentage = (currentAmount / targetAmount);
    if (percentage > 1.0) {
      return 1.0;
    }
    return percentage;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => GoalDetailsCard(
                title: title,
                currentAmount: currentAmount,
                targetAmount: targetAmount,
                percenatge: getPercentage(),
                startDate: getCreatedDate(),
                endDate: deadline,
              ),
            );
          },
          child: Row(
            children: [
              Expanded(
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isGoalComplete()
                          ? Colors.green
                              .shade100 // Change background color when complete
                          : Theme.of(context).colorScheme.surfaceDim,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        bottomLeft: const Radius.circular(15),
                        topRight: Radius.circular(_borderRadius),
                        bottomRight: Radius.circular(_borderRadius),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: isGoalComplete()
                                      ? Colors.green.shade200
                                      : const Color.fromARGB(
                                          255, 219, 228, 255),
                                ),
                                child: isGoalComplete()
                                    ? Lottie.asset(
                                        'assets/animations/goal-complete.json',
                                        width: 50,
                                        height: 50,
                                      )
                                    : Icon(
                                        IconSeletor.getIconForTitle(
                                            widget.title),
                                        size: 50,
                                        color: isGoalComplete()
                                            ? Colors.green
                                            : const Color(0xFF456EFE),
                                      ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isGoalComplete()
                                                ? Colors.black
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          '${(getPercentage() * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isGoalComplete()
                                                ? Colors.green
                                                : const Color(0xFF456EFE),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      getTimeRemaining(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (!isGoalComplete()) {
                                          final updatedGoal =
                                              await showDialog<Goal?>(
                                            context: context,
                                            builder: (context) =>
                                                GoalUpdatePopupCard(
                                              id: widget.id,
                                              targetAmount: targetAmount,
                                              deadLine: deadline,
                                              currentAmount: currentAmount,
                                              title: title,
                                              createdAt: widget.createdAt,
                                            ),
                                          );
                                          if (updatedGoal != null) {
                                            setState(() {
                                              title = updatedGoal.title;
                                              currentAmount =
                                                  updatedGoal.currentAmount;
                                              targetAmount =
                                                  updatedGoal.targetAmount;
                                              deadline = updatedGoal.deadline;
                                            });
                                          }
                                        }
                                      },
                                      style: ButtonStyle(
                                        padding:
                                            WidgetStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.only(
                                            right: 10,
                                            top: 5,
                                          ),
                                        ),
                                        minimumSize:
                                            WidgetStateProperty.all(Size.zero),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: isGoalComplete()
                                          ? Text(
                                              AppLocalizations.of(context)
                                                  .translate('goal_completed'),
                                              style: const TextStyle(
                                                color: Colors.green,
                                              ),
                                            )
                                          : Text(
                                              AppLocalizations.of(context)
                                                  .translate('update_progress'),
                                              style: const TextStyle(
                                                color: Color(0xFF456EFE),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        LinearPercentIndicator(
                          percent: getPercentage(),
                          progressColor: isGoalComplete()
                              ? Colors.green
                              : const Color(0xFF456EFE),
                          backgroundColor:
                              const Color.fromARGB(255, 219, 228, 255),
                          barRadius: const Radius.circular(20),
                          animation: true,
                          animationDuration: 1000,
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rs.${currentAmount.toString()}',
                                style: TextStyle(
                                  color: isGoalComplete() ? Colors.black : null,
                                ),
                              ),
                              Text(
                                'Rs.${targetAmount.toString()}',
                                style: TextStyle(
                                  color: isGoalComplete() ? Colors.black : null,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
