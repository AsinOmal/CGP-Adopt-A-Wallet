import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:financial_app/models/transaction.dart';
import 'package:financial_app/repositories/transaction/base_transaction_repository.dart';
import 'dart:developer' as dev;

import 'package:intl/intl.dart';

class TransactionRepository extends BaseTransactionRepository {
  final CollectionReference _transactionsCollection =
      FirebaseFirestore.instance.collection('transactions');
  final CollectionReference _budgetsCollection =
      FirebaseFirestore.instance.collection('budgets');

  @override
  Future<void> addTransaction({required Transaction transaction}) async {
    try {
      // Start a Firestore batch
      final batch = FirebaseFirestore.instance.batch();

      // Create a new document reference for the transaction
      final transactionDoc = _transactionsCollection.doc();
      transaction.id = transactionDoc.id;

      // Add the transaction to the batch
      batch.set(transactionDoc, transaction.toJson());

      // Check if a budget exists for the user and category
      final budgetQuery = await _budgetsCollection
          .where('userID', isEqualTo: transaction.userID)
          .where('category', isEqualTo: transaction.category)
          .limit(1)
          .get();

      if (budgetQuery.docs.isNotEmpty) {
        final budgetDoc = budgetQuery.docs.first;
        final budgetRef = budgetDoc.reference;

        // Calculate the new currentAmount
        final currentAmount = budgetDoc['currentAmount'] ?? 0.0;
        final newCurrentAmount = currentAmount + transaction.amount;

        // Update the budget's currentAmount in the batch
        batch.update(budgetRef, {'currentAmount': newCurrentAmount});
      }

      // Commit the batch to apply all changes
      await batch.commit();
      dev.log('Transaction added and budget updated successfully.');
    } catch (e) {
      dev.log('Error adding transaction and updating budget: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction({required String transactionID}) async {
    try {
      await _transactionsCollection.doc(transactionID).delete();
      dev.log('transaction delete success');
    } catch (e) {
      dev.log('transaction deleting error');
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactions({required String userID}) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('userID', isEqualTo: userID)
          .orderBy('createdAt', descending: true)
          .get();
      dev.log('transaction get success');
      return querySnapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      dev.log('transaction fetching error ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(
      {required String transactionID, required Transaction transaction}) async {
    try {
      await _transactionsCollection
          .doc(transactionID)
          .set(transaction.toJson(), SetOptions(merge: true));
      dev.log('transaction updated');
    } catch (e) {
      dev.log('transaction fail ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Map<String, double>> getTotalIncomeExpense(
      {required String userID}) async {
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    try {
      // Get the start of the current month
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      Timestamp startOfMonthTimestamp = Timestamp.fromDate(startOfMonth);

      // Calculate income for the current month
      QuerySnapshot incomeSnapshot = await _transactionsCollection
          .where('userID', isEqualTo: userID)
          .where('isIncome', isEqualTo: true)
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonthTimestamp)
          .get();

      for (var doc in incomeSnapshot.docs) {
        var transaction = Transaction.fromJson(doc.data());
        totalIncome += transaction.amount;
      }

      // Calculate expense for the current month
      QuerySnapshot expenseSnapshot = await _transactionsCollection
          .where('userID', isEqualTo: userID)
          .where('isIncome', isEqualTo: false)
          .where('createdAt', isGreaterThanOrEqualTo: startOfMonthTimestamp)
          .get();

      for (var doc in expenseSnapshot.docs) {
        var transaction = Transaction.fromJson(doc.data());
        totalExpense += transaction.amount;
      }

      dev.log('Monthly transaction totals updated');
      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
      };
    } catch (e) {
      dev.log('Error updating monthly transaction totals: $e');
      return {
        'totalIncome': 0.0,
        'totalExpense': 0.0,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getWeeklyTotals(
      {required String userID, required DateTime startDate}) async {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    List<String> dateRange = List.generate(7, (index) {
      return dateFormat.format(startDate.add(Duration(days: index)));
    });

    try {
      // Initialize Firestore query
      QuerySnapshot querySnapshot = await _transactionsCollection
          .where('userID', isEqualTo: userID)
          .where('date', whereIn: dateRange)
          .get();

      // Initialize a map to store daily income and expenses
      Map<String, Map<String, double>> dailyTotals = {
        for (var date in dateRange) date: {'income': 0.0, 'expense': 0.0}
      };

      for (var doc in querySnapshot.docs) {
        Transaction transaction = Transaction.fromJson(doc.data());

        // Ensure the transaction date is within the range
        if (dailyTotals.containsKey(transaction.date)) {
          if (transaction.isIncome) {
            dailyTotals[transaction.date]!['income'] =
                (dailyTotals[transaction.date]!['income'] ?? 0.0) +
                    transaction.amount;
          } else {
            dailyTotals[transaction.date]!['expense'] =
                (dailyTotals[transaction.date]!['expense'] ?? 0.0) +
                    transaction.amount;
          }
        }
      }

      // Convert the daily totals to a list of maps
      List<Map<String, dynamic>> weeklyTotals = dateRange.map((date) {
        return {
          'date': date,
          'income': dailyTotals[date]!['income'],
          'expense': dailyTotals[date]!['expense'],
        };
      }).toList();

      // Calculate the highest value across both income and expense
      double highestValue = 0.0;

      for (var dailyTotal in weeklyTotals) {
        highestValue = [
          highestValue,
          dailyTotal['income'],
          dailyTotal['expense']
        ].reduce((a, b) => a > b ? a : b);
      }

      return {
        'weeklyTotals': weeklyTotals,
        'highestValue': highestValue,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getMonthlyWeeklyAnalysis({
    required String userID,
    required int year,
    required int month,
  }) async {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    List<Map<String, dynamic>> weeklyTotals = [];
    double highestValue = 0.0;
    DateTime start = firstDayOfMonth;

    try {
      while (start.isBefore(lastDayOfMonth)) {
        // Define the end of the week, either 6 days after the start or the last day of the month
        DateTime end =
            start.add(const Duration(days: 6)).isBefore(lastDayOfMonth)
                ? start.add(const Duration(days: 6))
                : lastDayOfMonth;

        // Generate date range for the current week
        List<String> dateRange =
            List.generate(end.difference(start).inDays + 1, (index) {
          return dateFormat.format(start.add(Duration(days: index)));
        });

        // Initialize Firestore query
        QuerySnapshot querySnapshot = await _transactionsCollection
            .where('userID', isEqualTo: userID)
            .where('date', whereIn: dateRange)
            .get();

        // Initialize weekly income and expense totals
        double weeklyIncome = 0.0;
        double weeklyExpense = 0.0;

        for (var doc in querySnapshot.docs) {
          Transaction transaction = Transaction.fromJson(doc.data());

          if (transaction.isIncome) {
            weeklyIncome += transaction.amount;
          } else {
            weeklyExpense += transaction.amount;
          }
        }

        // Store weekly totals
        weeklyTotals.add({
          'weekStart': dateFormat.format(start),
          'weekEnd': dateFormat.format(end),
          'income': weeklyIncome,
          'expense': weeklyExpense,
        });

        // Update the highest value if this week has a higher income or expense
        highestValue = [highestValue, weeklyIncome, weeklyExpense]
            .reduce((a, b) => a > b ? a : b);

        // Move start to the next week
        start = end.add(const Duration(days: 1));
      }

      return {
        'weeklyTotals': weeklyTotals,
        'highestValue': highestValue,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getYearlyTotals({
    required String userID,
    required int year,
  }) async {
    try {
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');

      // Initialize a list to hold totals for each month
      List<Map<String, dynamic>> monthlyTotals = [];
      double highestAmount = 0.0;

      for (int month = 1; month <= 12; month++) {
        DateTime startDate = DateTime(year, month, 1);
        DateTime endDate =
            DateTime(year, month + 1, 0); // Last day of the month

        // Generate date range for the current month
        List<String> dateRange =
            List.generate(endDate.difference(startDate).inDays + 1, (index) {
          return dateFormat.format(startDate.add(Duration(days: index)));
        });

        double totalIncome = 0.0;
        double totalExpense = 0.0;

        // Batch the date range into chunks of 30 dates
        for (int i = 0; i < dateRange.length; i += 30) {
          // Get the chunk of dates (maximum 30)
          List<String> dateChunk = dateRange.sublist(
              i, i + 30 > dateRange.length ? dateRange.length : i + 30);

          // Initialize Firestore query for the chunk of dates
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('transactions')
              .where('userID', isEqualTo: userID)
              .where('date', whereIn: dateChunk)
              .get();

          // Calculate total income and expenses for this chunk
          for (var doc in querySnapshot.docs) {
            Transaction transaction = Transaction.fromJson(doc.data());

            if (transaction.isIncome) {
              totalIncome += transaction.amount;
            } else {
              totalExpense += transaction.amount;
            }
          }
        }

        // Add the monthly totals to the list
        monthlyTotals.add({
          'month': month,
          'totalIncome': totalIncome,
          'totalExpense': totalExpense,
        });

        // Track the highest value across all months
        highestAmount = [highestAmount, totalIncome, totalExpense]
            .reduce((a, b) => a > b ? a : b);
      }

      // Return the monthly totals and the highest value for the year
      return {
        'monthlyTotals': monthlyTotals,
        'highestAmount': highestAmount,
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getLastThreeYearsTotals({
    required String userID,
  }) async {
    DateTime currentDate = DateTime.now();
    int currentYear = currentDate.year;

    // Initialize a list to store yearly totals for the last 3 years
    List<Map<String, dynamic>> yearlyTotals = [];
    double highestAmountOverall = 0.0;

    // Iterate over the last 3 years
    for (int year = currentYear; year > currentYear - 3; year--) {
      DateFormat dateFormat = DateFormat('yyyy-MM-dd');

      double totalIncomeForYear = 0.0;
      double totalExpenseForYear = 0.0;

      // Loop through each month in the current year
      for (int month = 1; month <= 12; month++) {
        DateTime startDate = DateTime(year, month, 1);
        DateTime endDate =
            DateTime(year, month + 1, 0); // Last day of the month

        // Generate date range for the current month
        List<String> dateRange =
            List.generate(endDate.difference(startDate).inDays + 1, (index) {
          return dateFormat.format(startDate.add(Duration(days: index)));
        });

        double monthlyIncome = 0.0;
        double monthlyExpense = 0.0;

        // Batch the date range into chunks of 30 dates
        for (int i = 0; i < dateRange.length; i += 30) {
          // Get the chunk of dates (maximum 30)
          List<String> dateChunk = dateRange.sublist(
              i, i + 30 > dateRange.length ? dateRange.length : i + 30);

          try {
            // Firestore query for this chunk of dates
            QuerySnapshot querySnapshot = await _transactionsCollection
                .where('userID', isEqualTo: userID)
                .where('date', whereIn: dateChunk)
                .get();

            // Calculate income and expenses for this chunk
            for (var doc in querySnapshot.docs) {
              Transaction transaction = Transaction.fromJson(doc.data());

              if (transaction.isIncome) {
                monthlyIncome += transaction.amount;
              } else {
                monthlyExpense += transaction.amount;
              }
            }
          } catch (e) {
            dev.log(e.toString());
          }
        }

        // Update the yearly totals with the monthly totals
        totalIncomeForYear += monthlyIncome;
        totalExpenseForYear += monthlyExpense;

        // Track the highest value across all months in this year
        highestAmountOverall = [
          highestAmountOverall,
          monthlyIncome,
          monthlyExpense
        ].reduce((a, b) => a > b ? a : b);
      }

      // Add the totals for this year to the list
      yearlyTotals.add({
        'year': year,
        'totalIncome': totalIncomeForYear,
        'totalExpense': totalExpenseForYear,
      });
    }

    // Return the yearly totals and the highest value for the past 3 years
    return {
      'yearlyTotals': yearlyTotals,
      'highestAmountOverall': highestAmountOverall,
    };
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> getTransactionsForDateRange({
    required String userID,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Generate the list of dates within the range
    List<String> dateRange = List.generate(
      endDate.difference(startDate).inDays + 1,
      (index) => dateFormat.format(startDate.add(Duration(days: index))),
    );

    List<Map<String, dynamic>> incomeTransactions = [];
    List<Map<String, dynamic>> expenseTransactions = [];

    // Loop through the date range in chunks of 30 to avoid Firestore's limit
    for (int i = 0; i < dateRange.length; i += 30) {
      List<String> dateChunk = dateRange.sublist(
        i,
        i + 30 > dateRange.length ? dateRange.length : i + 30,
      );

      try {
        // Query Firestore for the current chunk of dates
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('transactions')
            .where('userID', isEqualTo: userID)
            .where('date', whereIn: dateChunk)
            .get();

        // Process each document in the query result
        for (var doc in querySnapshot.docs) {
          Transaction transaction = Transaction.fromJson(doc.data());

          // Create a map with only date, amount, and category
          Map<String, dynamic> transactionData = {
            'date': transaction.date,
            'amount': transaction.amount,
            'category': transaction.category,
          };

          // Add to the respective list based on isIncome
          if (transaction.isIncome) {
            incomeTransactions.add(transactionData);
          } else {
            expenseTransactions.add(transactionData);
          }
        }
      } catch (e) {
        dev.log(e.toString());
        rethrow;
      }
    }

    // Return the two lists as a map
    return {
      'income': incomeTransactions,
      'expense': expenseTransactions,
    };
  }
}
