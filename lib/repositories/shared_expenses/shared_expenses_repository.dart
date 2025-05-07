
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/models/group.dart';
import 'package:financial_app/repositories/shared_expenses/base_shared_expenses_repository.dart';
import 'dart:developer' as dev;

class SharedExpensesRepository extends BaseSharedExpensesRepository{

  final CollectionReference _sharedExpenseGroupCollection =
      FirebaseFirestore.instance.collection('shared_expense_groups');

  @override
  Future<void> addSharedExpenseGroup({ required Group group }) async {
    try {
      final doc = _sharedExpenseGroupCollection.doc();
      group.id = doc.id;
      await doc.set(group.toJson());
      dev.log('Shared expense group added successfully');
    } catch (e) {
      dev.log("Shared expense group add error: ${e.toString()}");
      rethrow;
    }
  }
}