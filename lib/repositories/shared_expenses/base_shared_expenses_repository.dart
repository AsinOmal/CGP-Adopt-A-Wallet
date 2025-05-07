import 'package:financial_app/models/group.dart';

abstract class BaseSharedExpensesRepository {
  Future<void> addSharedExpenseGroup ({required Group group});
}