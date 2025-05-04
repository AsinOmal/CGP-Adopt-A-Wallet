import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/models/goal.dart';
import 'package:financial_app/repositories/goal/base_goal_repository.dart';
import 'dart:developer' as developer;

class GoalRepository extends BaseGoalRepository {
  final CollectionReference _goalCollection =
      FirebaseFirestore.instance.collection('goals');

  @override
  Future<void> addGoal({required Goal goal}) async {
    try {
      final doc = _goalCollection.doc();
      goal.id = doc.id;
      await doc.set(goal.toJson());
      developer.log('goal add success');
    } catch (e) {
      developer.log('goal adding error ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> deleteGoal({required String goalID}) async {
    try {
      await _goalCollection.doc(goalID).delete();
      developer.log('goal delete success');
    } catch (e) {
      developer.log('goal delete error');
      rethrow;
    }
  }

  @override
  Future<List<Goal>> getGoals({required String userID}) async {
    try {
      final quertSnapshot = await _goalCollection
          .where('userID', isEqualTo: userID)
          .orderBy('createdAt', descending: true)
          .get();
      developer.log('goals get success');

      return quertSnapshot.docs
          .map((doc) => Goal.fromJson(doc.data()))
          .toList();
    } catch (e) {
      developer.log('goals fetching error ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> updateGoal({required String goalID, required Goal goal}) async {
    try {
      await _goalCollection
          .doc(goalID)
          .set(goal.toJson(), SetOptions(merge: true));
      developer.log('goal updated');
    } catch (e) {
      developer.log('goal update fail ${e.toString()}');
      rethrow;
    }
  }
}
