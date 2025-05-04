import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;

class DailyAnalysisChart extends StatefulWidget {
  const DailyAnalysisChart({
    super.key,
  });

  @override
  State<DailyAnalysisChart> createState() => _DailyAnalysisChartState();
}

class _DailyAnalysisChartState extends State<DailyAnalysisChart> {
  DateTime selectedDate = DateTime.now();
  DateTime? _startOfWeek;
  DateTime? _endOfWeek;
  late AuthRepository _authRepository;
  late TransactionBloc _transactionBloc;
  int scaleFactor = 1;

  void _pickWeek(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('en'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        _startOfWeek =
            picked.subtract(Duration(days: picked.weekday % 7)); // Sunday
        _endOfWeek = _startOfWeek!.add(const Duration(days: 6)); // Saturday
      });
      _transactionBloc.add(TransactionAnalysisDailyEvent(
          userID: _authRepository.userID, dateTime: _startOfWeek!));
    }
  }

  @override
  void initState() {
    super.initState();
    _startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    _endOfWeek = _startOfWeek!.add(const Duration(days: 6));
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _transactionBloc.add(TransactionAnalysisDailyEvent(
        userID: _authRepository.userID, dateTime: _startOfWeek!));
    // print(
    //     '${DateFormat('yyyy-MM-dd').format(_startOfWeek!)}  -  ${DateFormat('yyyy-MM-dd').format(_endOfWeek!)}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceDim,
            borderRadius: BorderRadius.circular(25)),
        height: 450,
        child: Column(
          children: [
            TextButton(
              onPressed: () => _pickWeek(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Baseline(
                    baselineType: TextBaseline.alphabetic,
                    baseline:
                        20.0, // Adjust this value to align text and icon properly
                    child: Text(
                      '${DateFormat('yyyy-MM-dd').format(_startOfWeek!)}  -  ${DateFormat('yyyy-MM-dd').format(_endOfWeek!)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Baseline(
                    baselineType: TextBaseline.alphabetic,
                    baseline:
                        20.0, // The same baseline value as the Text widget
                    child: Icon(
                      Icons.calendar_month,
                      color: Theme.of(context).colorScheme.secondaryFixed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                buildWhen: (previous, current) {
                  return current is TransactionAnalysisDailyLoading ||
                      current is TransactionAnalysisDailyLoaded ||
                      current is TransactionAnalysisDailyError;
                },
                builder: (context, state) {
                  if (state is TransactionAnalysisDailyLoaded) {
                    double highestVal = state.dailyTotals['highestValue'];
                    if (highestVal > 100000) {
                      scaleFactor = 10000;
                    } else if (highestVal > 10000) {
                      scaleFactor = 1000;
                    } else if (highestVal > 1000) {
                      scaleFactor = 100;
                    }
                    List<Map<String, dynamic>> weeklyTotals =
                        state.dailyTotals['weeklyTotals'];
                    var day1 = weeklyTotals[0];
                    var day2 = weeklyTotals[1];
                    var day3 = weeklyTotals[2];
                    var day4 = weeklyTotals[3];
                    var day5 = weeklyTotals[4];
                    var day6 = weeklyTotals[5];
                    var day7 = weeklyTotals[6];

                    // Access income and expense for each day
                    double day1Income = day1['income'] / scaleFactor;
                    double day1Expense = day1['expense'] / scaleFactor;
                    double day2Income = day2['income'] / scaleFactor;
                    double day2Expense = day2['expense'] / scaleFactor;
                    double day3Income = day3['income'] / scaleFactor;
                    double day3Expense = day3['expense'] / scaleFactor;
                    double day4Income = day4['income'] / scaleFactor;
                    double day4Expense = day4['expense'] / scaleFactor;
                    double day5Income = day5['income'] / scaleFactor;
                    double day5Expense = day5['expense'] / scaleFactor;
                    double day6Income = day6['income'] / scaleFactor;
                    double day6Expense = day6['expense'] / scaleFactor;
                    double day7Income = day7['income'] / scaleFactor;
                    double day7Expense = day7['expense'] / scaleFactor;
                    return buildBarChart(
                      day1Income,
                      day1Expense,
                      day2Income,
                      day2Expense,
                      day3Income,
                      day3Expense,
                      day4Income,
                      day4Expense,
                      day5Income,
                      day5Expense,
                      day6Income,
                      day6Expense,
                      day7Income,
                      day7Expense,
                    );
                  } else if (state is TransactionAnalysisDailyLoading) {
                    return const Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Fetching data...'),
                        SizedBox(height: 5),
                        SpinKitThreeBounce(
                          color: Colors.grey,
                          size: 50.0,
                        ),
                      ],
                    ));
                  }
                  return const Center(
                    child: SpinKitThreeBounce(
                      color: Colors.grey,
                      size: 50.0,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChart buildBarChart(
    double day1Income,
    double day1Expense,
    double day2Income,
    double day2Expense,
    double day3Income,
    double day3Expense,
    double day4Income,
    double day4Expense,
    double day5Income,
    double day5Expense,
    double day6Income,
    double day6Expense,
    double day7Income,
    double day7Expense,
  ) {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF456EFE),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final actualValue = rod.toY * scaleFactor;
              return BarTooltipItem(
                'Rs.${actualValue.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getTitlesOfY,
              interval: 10,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getTitlesOfX,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                  toY: double.parse(day1Income.toStringAsFixed(2)),
                  color: Colors.greenAccent),
              BarChartRodData(
                  toY: double.parse(day1Expense.toStringAsFixed(2)),
                  color: Colors.redAccent)
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                  toY: double.parse(day2Income.toStringAsFixed(2)),
                  color: Colors.greenAccent),
              BarChartRodData(
                  toY: double.parse(day2Expense.toStringAsFixed(2)),
                  color: Colors.redAccent)
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                  toY: double.parse(day3Income.toStringAsFixed(2)),
                  color: Colors.greenAccent),
              BarChartRodData(
                  toY: double.parse(day3Expense.toStringAsFixed(2)),
                  color: Colors.redAccent)
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                  toY: double.parse(day4Income.toStringAsFixed(2)),
                  color: Colors.greenAccent),
              BarChartRodData(
                  toY: double.parse(day4Expense.toStringAsFixed(2)),
                  color: Colors.redAccent)
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                  toY: double.parse(day5Income.toStringAsFixed(2)),
                  color: Colors.greenAccent),
              BarChartRodData(
                  toY: double.parse(day5Expense.toStringAsFixed(2)),
                  color: Colors.redAccent)
            ],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(
                  toY: double.parse(day6Income.toStringAsFixed(2)),
                  color: Colors.greenAccent),
              BarChartRodData(
                  toY: double.parse(day6Expense.toStringAsFixed(2)),
                  color: Colors.redAccent)
            ],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [
              BarChartRodData(
                  toY: double.parse(day7Income.toStringAsFixed(2)),
                  color: Colors.greenAccent),
              BarChartRodData(
                  toY: double.parse(day7Expense.toStringAsFixed(2)),
                  color: Colors.redAccent)
            ],
          ),
        ],
      ),
    );
  }

  Widget getTitlesOfX(value, meta) {
    switch (value.toInt()) {
      case 0:
        return const Text('Mon');
      case 1:
        return const Text('Tue');
      case 2:
        return const Text('Wed');
      case 3:
        return const Text('Thu');
      case 4:
        return const Text('Fri');
      case 5:
        return const Text('Sat');
      case 6:
        return const Text('Sun');
      default:
        return const Text('');
    }
  }

  Widget getTitlesOfY(value, meta) {
    dev.log(value.toString());
    return Text('${value * scaleFactor ~/ 1000}k');
  }
}
