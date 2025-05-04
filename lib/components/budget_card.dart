import 'package:financial_app/components/update_budget_popup.dart';
import 'package:financial_app/models/budget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BudgetCard extends StatefulWidget {
  final Budget budget;
  final void Function(BuildContext)? deleteFunction;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.deleteFunction,
  });

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard>
    with SingleTickerProviderStateMixin {
  double _borderRadius = 15.0; // Default border radius
  late final SlidableController _slidableController;
  late double targetAmount;

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
    targetAmount = widget.budget.amount;
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  double getPercentage() {
    double percentage = (widget.budget.currentAmount / widget.budget.amount);
    if (percentage > 1.0) {
      return 1.0;
    }
    return percentage;
  }

  bool isOverBudget() {
    return widget.budget.currentAmount > widget.budget.amount;
  }

  @override
  Widget build(BuildContext context) {
    final IconData? icon;
    switch (widget.budget.category) {
      case 'Food':
        icon = Icons.fastfood;
        break;
      case 'Sport':
        icon = Icons.sports_baseball;
        break;
      case 'Health':
        icon = Icons.local_hospital;
        break;
      case 'Transport':
        icon = Icons.directions_car;
        break;
      case 'Shopping':
        icon = Icons.shopping_cart;
        break;
      case 'Kids':
        icon = Icons.child_care;
        break;
      case 'Entertainment':
        icon = Icons.movie;
        break;
      case 'Education':
        icon = Icons.school;
        break;
      case 'Other':
        icon = Icons.category;
        break;
      default:
        icon = Icons.category;
    }
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
          onTap: () async {
            final updatedBudget = await showDialog<Budget>(
              context: context,
              builder: (context) => BudgetUpdatePopup(
                budget: widget.budget,
                icon: icon,
              ),
            );
            if (updatedBudget != null) {
              setState(() {
                targetAmount = updatedBudget.amount;
              });
              widget.budget.timePeriod = updatedBudget.timePeriod;
              widget.budget.amount = updatedBudget.amount;
            }
          },
          child: Row(
            children: [
              Expanded(
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceDim,
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOverBudget()
                                      ? Colors.red.shade100
                                      : const Color.fromARGB(
                                          255, 219, 228, 255),
                                ),
                                child: Icon(
                                  icon,
                                  size: 30,
                                  color: isOverBudget()
                                      ? Colors.red
                                      : const Color(0xFF456EFE),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.budget.category,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: isOverBudget()
                                                ? Colors.red
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          'Rs ${widget.budget.currentAmount.round()}/${targetAmount.round()}',
                                          style: TextStyle(
                                            color: isOverBudget()
                                                ? Colors.red
                                                : const Color(0xFF456EFE),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: LinearPercentIndicator(
                                            padding: EdgeInsets.zero,
                                            percent: getPercentage(),
                                            progressColor: isOverBudget()
                                                ? Colors.red
                                                : const Color(0xFF456EFE),
                                            backgroundColor: isOverBudget()
                                                ? Colors.red.shade100
                                                : const Color.fromARGB(
                                                    255, 219, 228, 255),
                                            barRadius:
                                                const Radius.circular(20),
                                            animation: true,
                                            animationDuration: 1000,
                                          ),
                                        ),
                                        Text(
                                          '${(getPercentage() * 100).round()}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: isOverBudget()
                                                ? Colors.red
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
