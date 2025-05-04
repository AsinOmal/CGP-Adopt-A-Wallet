import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class WeeklyAnalysisChart extends StatefulWidget {
  const WeeklyAnalysisChart({super.key});

  @override
  State<WeeklyAnalysisChart> createState() => _WeeklyAnalysisChartState();
}

class _WeeklyAnalysisChartState extends State<WeeklyAnalysisChart> {
  DateTime selectedDate = DateTime.now();
  late int year;
  late AuthRepository _authRepository;
  late TransactionBloc _transactionBloc;
  int scaleFactor = 1;
  List<BarChartGroupData> barChartGroupData = [];

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? pickedDate = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      lastDate: DateTime.now(),
      firstDate: DateTime(2000),
      monthPickerDialogSettings: MonthPickerDialogSettings(
        dialogSettings: const PickerDialogSettings(
          dialogRoundedCornersRadius: 15,
          locale: Locale('en'),
        ),
        headerSettings: const PickerHeaderSettings(
          headerBackgroundColor: Color(0xFF456EFE),
        ),
        buttonsSettings: PickerButtonsSettings(
          selectedMonthBackgroundColor: const Color(0xFF456EFE),
          selectedMonthTextColor: Colors.white,
          unselectedMonthsTextColor:
              Theme.of(context).colorScheme.secondaryFixed,
          currentMonthTextColor: Colors.green,
          yearTextStyle: const TextStyle(
            fontSize: 10,
          ),
        ),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        year = pickedDate.year;
      });
      _transactionBloc.add(TransactionAnalysisWeeklyEvent(
        userID: _authRepository.userID,
        year: year,
        month: selectedDate.month,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    year = selectedDate.year;
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _transactionBloc.add(TransactionAnalysisWeeklyEvent(
      userID: _authRepository.userID,
      year: year,
      month: selectedDate.month,
    ));
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
              onPressed: () => _selectMonthYear(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Baseline(
                    baselineType: TextBaseline.alphabetic,
                    baseline:
                        20.0, // Adjust this value to align text and icon properly
                    child: Text(
                      DateFormat('yyyy MMMM').format(selectedDate),
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
                builder: (context, state) {
                  if (state is TransactionAnalysisWeeklyLoading) {
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
                  } else if (state is TransactionAnalysisWeeklyLoaded) {
                    List<Map<String, dynamic>> weeklyTotals =
                        state.weeklyTotals['weeklyTotals'];
                    double highestVal = state.weeklyTotals['highestValue'];
                    if (highestVal > 100000) {
                      scaleFactor = 10000;
                    } else if (highestVal > 10000) {
                      scaleFactor = 1000;
                    } else if (highestVal > 1000) {
                      scaleFactor = 100;
                    }
                    if (highestVal == 0.0) {
                      return const Center(
                          child: Text('Not enough data to calaculations'));
                    }
                    _generateWeeklyBarChartData(weeklyTotals);

                    return buildBarChart();
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

  BarChart buildBarChart() {
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
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('W1');
                  case 1:
                    return const Text('W2');
                  case 2:
                    return const Text('W3');
                  case 3:
                    return const Text('W4');
                  case 4:
                    return const Text('W5');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: barChartGroupData,
      ),
    );
  }

  Widget getTitlesOfY(value, meta) {
    return Text('${value * scaleFactor ~/ 1000}k');
  }

  void _generateWeeklyBarChartData(List<Map<String, dynamic>> weeklyTotals) {
    barChartGroupData = [];
    for (int i = 0; i < weeklyTotals.length; i++) {
      final weekData = weeklyTotals[i];
      barChartGroupData.add(
        BarChartGroupData(
          x: i, // X-axis position for each week
          barRods: [
            BarChartRodData(
                toY: weekData['income'] / scaleFactor,
                color: Colors.greenAccent),
            BarChartRodData(
                toY: weekData['expense'] / scaleFactor, color: Colors.redAccent)
          ],
        ),
      );
    }
  }
}
