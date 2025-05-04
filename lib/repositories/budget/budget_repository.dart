import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/models/budget.dart';
import 'package:financial_app/repositories/budget/base_budget_repository.dart';
import 'dart:developer' as developer;

class BudgetRepository extends BaseBudgetRepository {
  final CollectionReference _budgetCollection =
      FirebaseFirestore.instance.collection('budgets');

  @override
  Future<void> addBugdet({required Budget budget}) async {
    try {
      // Check if a budget with the same category already exists for the user
      final existingBudgetQuery = await _budgetCollection
          .where('userID', isEqualTo: budget.userID)
          .where('category', isEqualTo: budget.category)
          .limit(1)
          .get();

      if (existingBudgetQuery.docs.isNotEmpty) {
        // A budget with the same category already exists, so log or handle the case
        developer.log(
            'Budget for category ${budget.category} already exists for this user.');
        throw Exception('A budget for this category already exists.');
      } else {
        // No existing budget found, proceed to add the new budget
        final doc = _budgetCollection.doc();
        budget.id = doc.id;
        await doc.set(budget.toJson());
        developer.log('Budget added successfully');
      }
    } catch (e) {
      developer.log('Budget add error: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget({required String budgetID}) async {
    try {
      await _budgetCollection.doc(budgetID).delete();
      developer.log('budget delete success');
    } catch (e) {
      developer.log('budget delete error');
      rethrow;
    }
  }

  @override
  Future<List<Budget>> getBudgets({required String userID}) async {
    try {
      final quertSnapshot = await _budgetCollection
          .where('userID', isEqualTo: userID)
          .orderBy('createdAt', descending: true)
          .get();
      developer.log('budgets get success');

      return quertSnapshot.docs
          .map((doc) => Budget.fromJson(doc.data()))
          .toList();
    } catch (e) {
      developer.log('budgets get error');
      rethrow;
    }
  }

  @override
  Future<void> updateBudget(
      {required String budgetID, required Budget budget}) async {
    try {
      await _budgetCollection
          .doc(budgetID)
          .set(budget.toJson(), SetOptions(merge: true));
      developer.log('budget is updated');
    } catch (e) {
      developer.log('budget update fail ${e.toString()}');
      rethrow;
    }
  }

  Future<void> resetBudgets() async {
    try {
      final currentTime = Timestamp.now();

      // Query budgets that need a weekly reset
      final weeklyBudgetsQuery = await _budgetCollection
          .where('timePeriod', isEqualTo: 'weekly')
          .get();

      // Query budgets that need a monthly reset
      final monthlyBudgetsQuery = await _budgetCollection
          .where('timePeriod', isEqualTo: 'monthly')
          .get();

      final batch = FirebaseFirestore.instance.batch();

      // Process weekly budgets
      for (var doc in weeklyBudgetsQuery.docs) {
        final lastReset = doc['lastReset'] as Timestamp;
        final resetThreshold = lastReset.toDate().add(const Duration(days: 7));
        if (currentTime.toDate().isAfter(resetThreshold)) {
          // Reset the budget
          batch.update(doc.reference, {
            'currentAmount': 0,
            'lastReset': currentTime,
          });
        }
      }

      // Process monthly budgets
      for (var doc in monthlyBudgetsQuery.docs) {
        final lastReset = doc['lastReset'] as Timestamp;
        final resetThreshold = lastReset.toDate().add(const Duration(days: 30));
        if (currentTime.toDate().isAfter(resetThreshold)) {
          // Reset the budget
          batch.update(doc.reference, {
            'currentAmount': 0,
            'lastReset': currentTime,
          });
        }
      }

      // Commit the batch
      await batch.commit();
      developer.log('Budget reset successfully completed.');
    } catch (e) {
      developer.log('Error resetting budgets: ${e.toString()}');
      rethrow;
    }
  }
}
