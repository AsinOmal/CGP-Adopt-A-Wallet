import 'package:financial_app/models/goal.dart';

abstract class BaseGoalRepository {
  Future<void> addGoal({required Goal goal});

  Future<List<Goal>> getGoals({required String userID});

  Future<void> deleteGoal({required String goalID});

  Future<void> updateGoal({required String goalID, required Goal goal});
}
