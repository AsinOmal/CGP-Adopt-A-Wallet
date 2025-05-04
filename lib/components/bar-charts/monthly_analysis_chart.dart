import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MonthlyAnalysisChart extends StatefulWidget {
  const MonthlyAnalysisChart({super.key});

  @override
  State<MonthlyAnalysisChart> createState() => _MonthlyAnalysisChartState();
}

class _MonthlyAnalysisChartState extends State<MonthlyAnalysisChart> {
  DateTime selectedYear = DateTime.now();
  bool isJanJunSelected = true;
  List<BarChartGroupData> barChartDataJan2Jun = [];
  List<BarChartGroupData> barChartDataJul2Dec = [];
  late AuthRepository _authRepository;
  late TransactionBloc _transactionBloc;
  int scaleFactor = 1;

  @override
  void initState() {
    super.initState();
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _transactionBloc.add(TransactionAnalysisMonthlyEvent(
        userID: _authRepository.userID, year: selectedYear.year));
  }

  void _toggleButtons() {
    setState(() {
      isJanJunSelected = !isJanJunSelected; // Swap the selection
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceDim,
          borderRadius: BorderRadius.circular(25),
        ),
        height: 350,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (!isJanJunSelected) _toggleButtons();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        isJanJunSelected ? const Color(0xFF456EFE) : null),
                    padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
                    minimumSize: const WidgetStatePropertyAll(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Jan-Jun',
                    style: TextStyle(
                      color: isJanJunSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showYearPicker(context),
                  child: Row(
                    children: [
                      Baseline(
                        baselineType: TextBaseline.alphabetic,
                        baseline: 20.0,
                        child: Text(
                          DateFormat('yyyy').format(selectedYear),
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
                        baseline: 20.0,
                        child: Icon(
                          Icons.calendar_month,
                          color: Theme.of(context).colorScheme.secondaryFixed,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (isJanJunSelected) _toggleButtons();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        isJanJunSelected ? null : const Color(0xFF456EFE)),
                    padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
                    minimumSize: const WidgetStatePropertyAll(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Jul-Dec',
                    style: TextStyle(
                      color: isJanJunSelected ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionAnalysisMonthlyLoaded) {
                    List<Map<String, dynamic>> monthlyTotals =
                        state.monthlyTotals['monthlyTotals'];
                    double highestVal = state.monthlyTotals['highestAmount'];
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
                    _generateWeeklyBarChartDataJan2Jun(monthlyTotals);
                    _generateWeeklyBarChartDataJul2Dec(monthlyTotals);
                    return buildBarChart();
                  } else if (state is TransactionAnalysisMonthlyLoading) {
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

  Future<dynamic> _showYearPicker(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Localizations.override(
              context: context,
              locale: const Locale('en'),
              child: YearPicker(
                firstDate: DateTime(DateTime.now().year - 100, 1),
                lastDate: DateTime.now(),
                selectedDate: selectedYear,
                onChanged: (DateTime dateTime) {
                  setState(() {
                    selectedYear = dateTime;
                  });
                  Navigator.pop(context);
                  _transactionBloc.add(TransactionAnalysisMonthlyEvent(
                      userID: _authRepository.userID, year: selectedYear.year));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  AnimatedSwitcher buildBarChart() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: BarChart(
        key: ValueKey<bool>(isJanJunSelected),
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
                getTitlesWidget: (value, meta) => isJanJunSelected
                    ? getJanToJunTitles(value, meta)
                    : getJulToDecTitles(value, meta),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups:
              isJanJunSelected ? barChartDataJan2Jun : barChartDataJul2Dec,
        ),
      ),
    );
  }

  void _generateWeeklyBarChartDataJan2Jun(
      List<Map<String, dynamic>> monthlyTotals) {
    barChartDataJan2Jun = [];
    for (int i = 0; i <= 5; i++) {
      final weekData = monthlyTotals[i];
      barChartDataJan2Jun.add(
        BarChartGroupData(
          x: i, // X-axis position for each week
          barRods: [
            BarChartRodData(
                toY: weekData['totalIncome'] / scaleFactor,
                color: Colors.greenAccent),
            BarChartRodData(
                toY: weekData['totalExpense'] / scaleFactor,
                color: Colors.redAccent)
          ],
        ),
      );
    }
  }

  void _generateWeeklyBarChartDataJul2Dec(
      List<Map<String, dynamic>> monthlyTotals) {
    barChartDataJul2Dec = [];
    for (int i = 6; i <= 11; i++) {
      final weekData = monthlyTotals[i];
      barChartDataJul2Dec.add(
        BarChartGroupData(
          x: i, // X-axis position for each week
          barRods: [
            BarChartRodData(
                toY: weekData['totalIncome'] / scaleFactor,
                color: Colors.greenAccent),
            BarChartRodData(
                toY: weekData['totalExpense'] / scaleFactor,
                color: Colors.redAccent)
          ],
        ),
      );
    }
  }

  Widget getTitlesOfY(value, meta) {
    return Text('${value * scaleFactor ~/ 1000}k');
  }

  Widget getJanToJunTitles(value, meta) {
    switch (value.toInt()) {
      case 0:
        return const Text('Jan');
      case 1:
        return const Text('Feb');
      case 2:
        return const Text('Mar');
      case 3:
        return const Text('Apr');
      case 4:
        return const Text('May');
      case 5:
        return const Text('Jun');
      default:
        return const Text('');
    }
  }

  Widget getJulToDecTitles(value, meta) {
    switch (value.toInt()) {
      case 6:
        return const Text('Jul');
      case 7:
        return const Text('Aug');
      case 8:
        return const Text('Sep');
      case 9:
        return const Text('Oct');
      case 10:
        return const Text('Nov');
      case 11:
        return const Text('Dec');
      default:
        return const Text('');
    }
  }
}
