part of 'transaction_bloc.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

final class TransactionInitial extends TransactionState {}

// * TRANSACTION ADD STATES
final class TransactionSuccess extends TransactionState {}

final class TransactionLoading extends TransactionState {}

final class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object> get props => [message];
}

// * TRANSACTION FETCH STATES

final class TransactionEmpty extends TransactionState {}

final class TransactionFetchLoading extends TransactionState {}

final class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionLoaded({required this.transactions});
}

// * TRANSACTION DELETE STATES

final class TransactionDeleteSuccess extends TransactionState {}

// * TRANSACTION UPDATE STATES

final class TransactionUpdateLoading extends TransactionState {}

final class TrnsactionUpdateSuccess extends TransactionState {}

final class TransactionUpdateError extends TransactionState {
  final String message;

  const TransactionUpdateError({required this.message});

  @override
  List<Object> get props => [message];
}

// * TRANSACTION GET TOTAL STATES

final class TransactionGetTotalLoading extends TransactionState {}

final class TransactionGetTotalLoaded extends TransactionState {
  final Map<String, double> totalIncomeExpense;

  const TransactionGetTotalLoaded({required this.totalIncomeExpense});

  @override
  List<Object> get props => [totalIncomeExpense];
}

final class TransactionGetTotalError extends TransactionState {
  final String message;

  const TransactionGetTotalError({required this.message});

  @override
  List<Object> get props => [message];
}

// * TRANSACTION DAILY ANALYSIS STATES

final class TransactionAnalysisDailyLoaded extends TransactionState {
  final Map<String, dynamic> dailyTotals;

  const TransactionAnalysisDailyLoaded({required this.dailyTotals});

  @override
  List<Object> get props => [dailyTotals];
}

final class TransactionAnalysisDailyLoading extends TransactionState {}

final class TransactionAnalysisDailyError extends TransactionState {
  final String message;

  const TransactionAnalysisDailyError({required this.message});

  @override
  List<Object> get props => [message];
}

// * TRANSACTION WEEKLY ANALYSIS STATES

final class TransactionAnalysisWeeklyLoaded extends TransactionState {
  final Map<String, dynamic> weeklyTotals;

  const TransactionAnalysisWeeklyLoaded({required this.weeklyTotals});

  @override
  List<Object> get props => [weeklyTotals];
}

final class TransactionAnalysisWeeklyLoading extends TransactionState {}

final class TransactionAnalysisWeeklyError extends TransactionState {
  final String message;

  const TransactionAnalysisWeeklyError({required this.message});

  @override
  List<Object> get props => [message];
}

// * TRANSACTION MONTHLY ANALYSIS STATES

final class TransactionAnalysisMonthlyLoaded extends TransactionState {
  final Map<String, dynamic> monthlyTotals;

  const TransactionAnalysisMonthlyLoaded({required this.monthlyTotals});

  @override
  List<Object> get props => [monthlyTotals];
}

final class TransactionAnalysisMonthlyLoading extends TransactionState {}

final class TransactionAnalysisMonthlyError extends TransactionState {
  final String message;

  const TransactionAnalysisMonthlyError({required this.message});

  @override
  List<Object> get props => [message];
}

// * TRANSACTION YEARLY ANALYSIS STATES

final class TransactionAnalysisYearlyLoaded extends TransactionState {
  final Map<String, dynamic> yearlyTotals;

  const TransactionAnalysisYearlyLoaded({required this.yearlyTotals});

  @override
  List<Object> get props => [yearlyTotals];
}

final class TransactionAnalysisYearlyLoading extends TransactionState {}

final class TransactionAnalysisYearlyError extends TransactionState {
  final String message;

  const TransactionAnalysisYearlyError({required this.message});

  @override
  List<Object> get props => [message];
}

// * TRANSACTION YEARLY ANALYSIS STATES

final class TransactionDateRangeLoaded extends TransactionState {
  final Map<String, List<Map<String, dynamic>>> transactionsMap;

  const TransactionDateRangeLoaded({required this.transactionsMap});

  @override
  List<Object> get props => [transactionsMap];
}

final class TransactionDateRangeLoading extends TransactionState {}

final class TransactionDateRangeError extends TransactionState {
  final String message;

  const TransactionDateRangeError({required this.message});

  @override
  List<Object> get props => [message];
}
