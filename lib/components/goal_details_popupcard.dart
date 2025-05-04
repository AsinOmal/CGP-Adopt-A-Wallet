import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class GoalDetailsCard extends StatefulWidget {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String startDate;
  final String endDate;
  final double percenatge;

  const GoalDetailsCard({
    super.key,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    required this.percenatge,
  });

  @override
  State<GoalDetailsCard> createState() => _GoalDetailsCardState();
}

class _GoalDetailsCardState extends State<GoalDetailsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController and the fade animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start with the fully visible widget
    _controller.forward();
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is removed
    _controller.dispose();
    super.dispose();
  }

  void _closeCard(BuildContext context) {
    // Trigger the fade-out animation
    _controller.reverse().then((_) {
      // Pop the page after the animation completes
      Navigator.pop(context);
    });
  }

  String formatEndDate() {
    return widget.endDate.replaceAll('-', '/');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation, // Apply the fade animation
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircularPercentIndicator(
                          progressColor: const Color(0xFF456EFE),
                          backgroundColor:
                              const Color.fromARGB(255, 219, 228, 255),
                          radius: 30,
                          percent: widget.percenatge,
                          animation: true,
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Text('${(widget.percenatge * 100).round()}%'),
                        ),
                        Text(
                          widget.title,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          AppLocalizations.of(context).translate('target_amount_label'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFbabcbb),
                          ),
                        ),
                        Text(widget.targetAmount.toString()),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          AppLocalizations.of(context).translate('current_amount_label'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFbabcbb),
                          ),
                        ),
                        Text(widget.currentAmount.toString()),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          AppLocalizations.of(context).translate('start_date_label'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFbabcbb),
                          ),
                        ),
                        Text(widget.startDate),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          AppLocalizations.of(context).translate('end_date_label'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFbabcbb),
                          ),
                        ),
                        Text(formatEndDate()),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextButton(
                      onPressed: () {
                        _closeCard(context);
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('close'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
