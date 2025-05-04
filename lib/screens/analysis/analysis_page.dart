import 'package:financial_app/blocs/transaction/transaction_bloc.dart';
import 'package:financial_app/components/bar-charts/daily_analysis_chart.dart';
import 'package:financial_app/components/bar-charts/monthly_analysis_chart.dart';
import 'package:financial_app/components/bar-charts/weekly_analysis_chart.dart';
import 'package:financial_app/components/bar-charts/yearly_analysis_chart.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:financial_app/services/generate_pdf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  DateTime endDate = DateTime.now();
  late DateTime startDate;
  late AuthRepository _authRepository;
  late TransactionBloc _transactionBloc;
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    startDate = endDate.subtract(const Duration(days: 30));
    _tabController = TabController(length: 4, vsync: this);

    _pageController = PageController();
    _tabController.addListener(() {
      setState(() {});
    });
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
    _transactionBloc = RepositoryProvider.of<TransactionBloc>(context);
    _transactionBloc
        .add(TransactionGetTotalsEvent(userID: _authRepository.userID));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) {
        return current is TransactionDateRangeLoading ||
            current is TransactionDateRangeLoaded ||
            current is TransactionDateRangeError;
      },
      listener: (context, state) async {
        if (state is TransactionDateRangeLoading) {
          showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: SpinKitThreeBounce(
                  color: Colors.white,
                  size: 50.0,
                ),
              );
            },
          );
        } else if (state is TransactionDateRangeLoaded) {
          Navigator.pop(context);
          List<Map<String, dynamic>> incomeList =
              state.transactionsMap['income']!;
          List<Map<String, dynamic>> expenseList =
              state.transactionsMap['expense']!;
          String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
          String endDateString = DateFormat('yyyy-MM-dd').format(endDate);

          await generateAndShowPdf(
              context, incomeList, expenseList, startDateString, endDateString);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF456EFE),
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context).translate('analysis'),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF456EFE),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocListener<TransactionBloc, TransactionState>(
                    listenWhen: (previous, current) {
                      return current is TransactionGetTotalLoading ||
                          current is TransactionGetTotalLoaded ||
                          current is TransactionGetTotalError;
                    },
                    listener: (context, state) {
                      if (state is TransactionGetTotalLoaded) {
                        setState(() {
                          totalIncome =
                              state.totalIncomeExpense['totalIncome'] ?? 0.0;
                          totalExpense =
                              state.totalIncomeExpense['totalExpense'] ?? 0.0;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rs.${totalIncome.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('monthly_income'),
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Rs.${totalExpense.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('monthly_expense'),
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: DefaultTabController(
                        animationDuration: const Duration(milliseconds: 600),
                        length: 4, // Number of tabs
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceDim,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            dividerHeight: 0,
                            overlayColor: const WidgetStatePropertyAll(
                                Colors.transparent),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            indicator: BoxDecoration(
                              color: const Color(
                                  0xFF456EFE), // Color of the selected tab
                              borderRadius: BorderRadius.circular(
                                  30.0), // Rounded corners for selected tab
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              SizedBox(
                                width: 80,
                                child: Tab(
                                  text: AppLocalizations.of(context)
                                      .translate('daily'),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Tab(
                                  text: AppLocalizations.of(context)
                                      .translate('weekly'),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Tab(
                                  text: AppLocalizations.of(context)
                                      .translate('monthly'),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Tab(
                                  text: AppLocalizations.of(context)
                                      .translate('yearly'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 450,
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          DailyAnalysisChart(),
                          WeeklyAnalysisChart(),
                          MonthlyAnalysisChart(),
                          YearlyAnalysisChart(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)
                            .translate('start_date_label'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .translate('end_date_label'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Baseline(
                            baselineType: TextBaseline.alphabetic,
                            baseline: 20.0,
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(startDate),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryFixed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Baseline(
                            baselineType: TextBaseline.alphabetic,
                            baseline: 20.0,
                            child: GestureDetector(
                              onTap: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      height: 250,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                        ),
                                        child: CupertinoTheme(
                                          data: CupertinoThemeData(
                                            textTheme: CupertinoTextThemeData(
                                              dateTimePickerTextStyle:
                                                  TextStyle(
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryFixed,
                                              ),
                                            ),
                                            primaryColor:
                                                CupertinoColors.activeGreen,
                                            scaffoldBackgroundColor:
                                                CupertinoColors
                                                    .lightBackgroundGray,
                                          ),
                                          child: Localizations.override(
                                            context: context,
                                            locale: const Locale('en'),
                                            child: CupertinoDatePicker(
                                              initialDateTime: startDate,
                                              maximumDate: DateTime.now(),
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              backgroundColor:
                                                  Colors.transparent,
                                              onDateTimeChanged: (value) {
                                                setState(() {
                                                  startDate = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Icon(
                                Icons.calendar_month,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryFixed,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Baseline(
                            baselineType: TextBaseline.alphabetic,
                            baseline: 20.0,
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(endDate),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryFixed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Baseline(
                            baselineType: TextBaseline.alphabetic,
                            baseline: 20.0,
                            child: GestureDetector(
                              onTap: () {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      height: 250,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20.0),
                                            topRight: Radius.circular(20.0),
                                          ),
                                        ),
                                        child: CupertinoTheme(
                                          data: CupertinoThemeData(
                                            textTheme: CupertinoTextThemeData(
                                              dateTimePickerTextStyle:
                                                  TextStyle(
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryFixed,
                                              ),
                                            ),
                                            primaryColor:
                                                CupertinoColors.activeGreen,
                                            scaffoldBackgroundColor:
                                                CupertinoColors
                                                    .lightBackgroundGray,
                                          ),
                                          child: Localizations.override(
                                            context: context,
                                            locale: const Locale('en'),
                                            child: CupertinoDatePicker(
                                              initialDateTime: endDate,
                                              maximumDate: DateTime.now(),
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              backgroundColor:
                                                  Colors.transparent,
                                              onDateTimeChanged: (value) {
                                                setState(() {
                                                  endDate = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Icon(
                                Icons.calendar_month,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryFixed,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: SimpleButton(
                data: AppLocalizations.of(context).translate('generate_report'),
                onPressed: () {
                  _transactionBloc.add(
                    TransactionFetchDateRangeEvent(
                      startDate,
                      endDate,
                      userID: _authRepository.userID,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
