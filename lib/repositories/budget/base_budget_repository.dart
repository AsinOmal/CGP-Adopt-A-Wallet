import 'package:financial_app/models/budget.dart';

abstract class BaseBudgetRepository {
  Future<void> addBugdet({required Budget budget});

  Future<List<Budget>> getBudgets({required String userID});

  Future<void> deleteBudget({required String budgetID});

  Future<void> updateBudget({required String budgetID, required Budget budget});
}
