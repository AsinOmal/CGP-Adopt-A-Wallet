import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:financial_app/models/transaction.dart';
import 'package:financial_app/repositories/transaction/transaction_repository.dart';
import 'dart:developer' as dev;
part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc(this._transactionRepository) : super(TransactionInitial()) {
    on<TransactionEvent>((event, emit) async {
      // * transaction add event
      if (event is TransactionAddEvent) {
        try {
          emit(TransactionLoading());
          await _transactionRepository.addTransaction(
              transaction: event.transaction);
          await Future.delayed(const Duration(seconds: 1));
          emit(TransactionSuccess());
        } catch (e) {
          emit(const TransactionError(message: 'Error occurred!'));
        }
      }
      // * transaction fetch event
      if (event is TransactionFetchEvent) {
        emit(TransactionFetchLoading());
        try {
          final transactions = await _transactionRepository.getTransactions(
            userID: event.userID,
          );
          if (transactions.isNotEmpty) {
            emit(TransactionLoaded(transactions: transactions));
          } else {
            emit(TransactionEmpty());
          }
        } catch (e) {
          emit(const TransactionError(message: 'Error occurred!'));
        }
      }
      // * transaction delete event
      if (event is TransactionDeleteEvent) {
        try {
          await _transactionRepository.deleteTransaction(
              transactionID: event.transactionID);
          emit(TransactionDeleteSuccess());
        } catch (e) {
          emit(const TransactionError(message: 'Error occurred!'));
        }
      }
      // * transaction update event
      if (event is TransactionUpdateEvent) {
        try {
          emit(TransactionUpdateLoading());
          await _transactionRepository.updateTransaction(
            transactionID: event.transactionID,
            transaction: event.transaction,
          );
          await Future.delayed(const Duration(milliseconds: 500));
          emit(TrnsactionUpdateSuccess());
        } catch (e) {
          await Future.delayed(const Duration(milliseconds: 500));
          emit(const TransactionUpdateError(message: 'Error occurred!'));
        }
      }
      // * transaction get totals event
      if (event is TransactionGetTotalsEvent) {
        try {
          emit(TransactionGetTotalLoading());
          final totalIncomeExpense = await _transactionRepository
              .getTotalIncomeExpense(userID: event.userID);
          emit(TransactionGetTotalLoaded(
              totalIncomeExpense: totalIncomeExpense));
        } catch (e) {
          emit(const TransactionGetTotalError(message: 'Error occured'));
        }
      }
      // * transaction daily totals event
      if (event is TransactionAnalysisDailyEvent) {
        try {
          emit(TransactionAnalysisDailyLoading());
          await Future.delayed(const Duration(seconds: 1));
          final result = await _transactionRepository.getWeeklyTotals(
              userID: event.userID, startDate: event.dateTime);
          emit(TransactionAnalysisDailyLoaded(dailyTotals: result));
        } catch (e) {
          emit(const TransactionAnalysisDailyError(message: 'Error occured'));
        }
      }
      // * transaction weekly totals event
      if (event is TransactionAnalysisWeeklyEvent) {
        try {
          emit(TransactionAnalysisWeeklyLoading());
          final result = await _transactionRepository.getMonthlyWeeklyAnalysis(
              userID: event.userID, year: event.year, month: event.month);
          emit(TransactionAnalysisWeeklyLoaded(weeklyTotals: result));
        } catch (e) {
          emit(const TransactionAnalysisWeeklyError(message: 'Error occured'));
        }
      }
      // * transaction monthly totals event
      if (event is TransactionAnalysisMonthlyEvent) {
        try {
          emit(TransactionAnalysisMonthlyLoading());
          final result = await _transactionRepository.getYearlyTotals(
              userID: event.userID, year: event.year);
          emit(TransactionAnalysisMonthlyLoaded(monthlyTotals: result));
        } catch (e) {
          dev.log(e.toString());
          emit(const TransactionAnalysisMonthlyError(message: 'Error occured'));
        }
      }
      // * transaction yearly totals event
      if (event is TransactionAnalysisYearlyEvent) {
        try {
          emit(TransactionAnalysisYearlyLoading());
          final result = await _transactionRepository.getLastThreeYearsTotals(
              userID: event.userID);
          emit(TransactionAnalysisYearlyLoaded(yearlyTotals: result));
        } catch (e) {
          dev.log(e.toString());
          emit(const TransactionAnalysisYearlyError(message: 'Error occured'));
        }
      }
      // * transaction date range fetch event
      if (event is TransactionFetchDateRangeEvent) {
        try {
          emit(TransactionDateRangeLoading());
          final result =
              await _transactionRepository.getTransactionsForDateRange(
            userID: event.userID,
            startDate: event.startDate,
            endDate: event.endDate,
          );
          emit(TransactionDateRangeLoaded(transactionsMap: result));
        } catch (e) {
          dev.log(e.toString());
          emit(const TransactionDateRangeError(message: 'Error occured'));
        }
      }
    });
  }
}
