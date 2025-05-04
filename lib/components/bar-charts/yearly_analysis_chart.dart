import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class YearlyAnalysisChart extends StatefulWidget {
  const YearlyAnalysisChart({super.key});

  @override
  State<YearlyAnalysisChart> createState() => _YearlyAnalysisChartState();
}

class _YearlyAnalysisChartState extends State<YearlyAnalysisChart> {
  late AuthRepository _authRepository;
  late TransactionBloc _transactionBloc;
  int scaleFactor = 1;
  List<BarChartGroupData> barChartGroupData = [];
  List<int> years = [];

  @override
  void initState() {
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _transactionBloc
        .add(TransactionAnalysisYearlyEvent(userID: _authRepository.userID));
    super.initState();
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
        height: 350,
        child: Column(
          children: [
            TextButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Baseline(
                    baselineType: TextBaseline.alphabetic,
                    baseline:
                        20.0, // Adjust this value to align text and icon properly
                    child: Text(
                      'Last 3 Years',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
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
                  return current is TransactionAnalysisYearlyLoading ||
                      current is TransactionAnalysisYearlyLoaded ||
                      current is TransactionAnalysisYearlyError;
                },
                builder: (context, state) {
                  if (state is TransactionAnalysisYearlyLoaded) {
                    List<Map<String, dynamic>> yearlyTotals =
                        state.yearlyTotals['yearlyTotals'];
                    double highestVal =
                        state.yearlyTotals['highestAmountOverall'];
                    if (highestVal > 100000) {
                      scaleFactor = 10000;
                    } else if (highestVal > 10000) {
                      scaleFactor = 1000;
                    } else if (highestVal > 1000) {
                      scaleFactor = 100;
                    }
                    _generateYearlyBarChartData(yearlyTotals);
                    return buildBarChart();
                  } else if (state is TransactionAnalysisYearlyLoading) {
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
                    return Text('${years[0]}');
                  case 1:
                    return Text('${years[1]}');
                  case 2:
                    return Text('${years[2]}');
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

  void _generateYearlyBarChartData(List<Map<String, dynamic>> yearlyTotals) {
    barChartGroupData = [];
    years = [];
    for (int i = 0; i < yearlyTotals.length; i++) {
      final yearData = yearlyTotals[i];
      years.add(yearData['year']);
      barChartGroupData.add(
        BarChartGroupData(
          x: i, // X-axis position for each week
          barRods: [
            BarChartRodData(
                toY: yearData['totalIncome'] / scaleFactor,
                color: Colors.greenAccent),
            BarChartRodData(
                toY: yearData['totalExpense'] / scaleFactor,
                color: Colors.redAccent)
          ],
        ),
      );
    }
  }
}
